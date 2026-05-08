import Foundation
import Darwin

// MARK: - 11B.3 MemoryLayout

print("--- 11B.3 MemoryLayout ---")
print("Int size:", MemoryLayout<Int>.size)             // 8
print("Double size:", MemoryLayout<Double>.size)        // 8
print("Bool size:", MemoryLayout<Bool>.size)            // 1
print("String size:", MemoryLayout<String>.size)        // 16
print("Optional<Int> size:", MemoryLayout<Optional<Int>>.size)  // 9 или 16

struct Point {
    var x: Int
    var y: Int
}
print("Point size:", MemoryLayout<Point>.size)          // 16

struct Data3D {
    var x, y, z: Double
    var label: String
}
print("Data3D size:", MemoryLayout<Data3D>.size)        // 40

print("Bool stride:", MemoryLayout<Bool>.stride)        // 1
print("Bool alignment:", MemoryLayout<Bool>.alignment)  // 1
print("Int stride:", MemoryLayout<Int>.stride)          // 8

// MARK: - 11B.5 Padding

struct PaddedPoor {
    var flag: Bool
    var value: Int
}

struct PaddedGood {
    var value: Int
    var flag: Bool
}

print("--- 11B.5 Padding ---")
print("PaddedPoor size:", MemoryLayout<PaddedPoor>.size)
print("PaddedPoor stride:", MemoryLayout<PaddedPoor>.stride)
print("PaddedGood size:", MemoryLayout<PaddedGood>.size)
print("PaddedGood stride:", MemoryLayout<PaddedGood>.stride)

// MARK: - 11B.4 Сравнение struct vs class

struct PointStruct {
    var x: Int
    var y: Int
}

class PointClass {
    var x: Int = 0
    var y: Int = 0
}

print("--- 11B.4 struct vs class size ---")
print("PointStruct size:", MemoryLayout<PointStruct>.size)         // 16
print("PointClass size (указатель):", MemoryLayout<PointClass>.size)  // 8

// MARK: - 11B.5 ARC через deinit

class Resource {
    let name: String
    init(name: String) {
        self.name = name
        print("Создан \(name)")
    }
    deinit {
        print("Уничтожен \(name)")
    }
}

print("--- 11B.5 ARC ---")
do {
    let r1 = Resource(name: "A")
    let r2 = r1   // refCount: 2
    print("r2.name:", r2.name)
}
// при выходе из do — оба ссылочных уничтожаются
// "Уничтожен A" печатается ровно один раз (один объект, две ссылки)

// MARK: - 11B.8 Retain cycle (без weak)

class OwnerLeaky {
    let name: String
    var pet: PetLeaky?
    init(name: String) {
        self.name = name
        print("OwnerLeaky \(name) создан")
    }
    deinit { print("OwnerLeaky \(name) уничтожен") }
}

class PetLeaky {
    let name: String
    var owner: OwnerLeaky?
    init(name: String) {
        self.name = name
        print("PetLeaky \(name) создан")
    }
    deinit { print("PetLeaky \(name) уничтожен") }
}

print("--- 11B.8 retain cycle (без weak) ---")
do {
    let alice = OwnerLeaky(name: "Айгерим")
    let rex = PetLeaky(name: "Рекс")
    alice.pet = rex
    rex.owner = alice
}
// deinit не печатается — cycle

// MARK: - 11B.8 Починка через weak

class OwnerFixed {
    let name: String
    var pet: PetFixed?
    init(name: String) {
        self.name = name
        print("OwnerFixed \(name) создан")
    }
    deinit { print("OwnerFixed \(name) уничтожен") }
}

class PetFixed {
    let name: String
    weak var owner: OwnerFixed?    // weak — разрывает cycle
    init(name: String) {
        self.name = name
        print("PetFixed \(name) создан")
    }
    deinit { print("PetFixed \(name) уничтожен") }
}

print("--- 11B.8 С weak (починка) ---")
do {
    let alice = OwnerFixed(name: "Айгерим")
    let rex = PetFixed(name: "Рекс")
    alice.pet = rex
    rex.owner = alice
}
// оба deinit печатаются

// MARK: - 11B.6 weak ссылка может стать nil

class Object {
    let id: Int
    init(id: Int) { self.id = id }
}

print("--- 11B.6 weak обнуляется ---")
weak var weakRef: Object?
do {
    let obj = Object(id: 42)
    weakRef = obj
    print("в do: weakRef =", weakRef?.id ?? "nil")
}
// после do obj уничтожен, weakRef автоматически nil
print("после do: weakRef =", weakRef?.id ?? "nil")

// MARK: - 11B.7 Copy-on-write

print("--- 11B.7 Copy-on-write ---")
var a = Array(repeating: 0, count: 1000)
var b = a   // не копирует данные — обе указывают на один buffer

// проверка через isKnownUniquelyReferenced требует low-level доступа,
// для демонстрации просто меняем и видим что b независим
b[0] = 99
print("a[0] =", a[0], "b[0] =", b[0])

// MARK: - 11B.2 Замер памяти

func memoryUsageMB() -> Double {
    var info = mach_task_basic_info()
    var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size / MemoryLayout<integer_t>.size)

    let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
        $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
            task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
        }
    }

    guard kerr == KERN_SUCCESS else { return 0 }
    return Double(info.resident_size) / 1024.0 / 1024.0
}

print("--- 11B.2 Замер памяти ---")
let before = memoryUsageMB()
print(String(format: "До: %.2f МБ", before))

do {
    let arr = Array(repeating: 42, count: 1_000_000)
    let mid = memoryUsageMB()
    print(String(format: "После создания (1M Int = ~8 МБ): %.2f МБ (+%.2f)", mid, mid - before))
    _ = arr.count
}

let after = memoryUsageMB()
print(String(format: "После выхода: %.2f МБ", after))

// MARK: - 11B.9 Источник утечек: Closure захватывает self

class CartLeaky {
    var onChange: (() -> Void)?
    let id = UUID().uuidString.prefix(8)

    func setup() {
        onChange = {
            print("CartLeaky \(self.id) onChange")
        }
    }

    deinit { print("CartLeaky \(id) deinit") }
}

class CartFixed {
    var onChange: (() -> Void)?
    let id = UUID().uuidString.prefix(8)

    func setup() {
        onChange = { [weak self] in
            print("CartFixed \(self?.id ?? "?") onChange")
        }
    }

    deinit { print("CartFixed \(id) deinit") }
}

print("--- 11B.9 Closure cycle ---")
do {
    let cart = CartLeaky()
    cart.setup()
    print("CartLeaky создан, id:", cart.id)
}
// CartLeaky — нет deinit (cycle через onChange → self)

do {
    let cart = CartFixed()
    cart.setup()
    print("CartFixed создан, id:", cart.id)
}
// CartFixed — deinit печатается ([weak self] разорвал cycle)

print("--- Done ---")
