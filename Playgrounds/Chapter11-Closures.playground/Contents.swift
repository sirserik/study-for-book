import Foundation

// MARK: - 11.1/11.2 Базовое замыкание

let greet = { print("Сәлем!") }
print("--- 11.2 базовое ---")
greet()
greet()

// MARK: - 11.3 С параметрами

let multiply: (Int, Int) -> Int = { a, b in a * b }
print("--- 11.3 параметры ---")
print("multiply(3, 4) =", multiply(3, 4))

// MARK: - 11.4/11.5 Trailing closure

func doTwice(action: () -> Void) {
    action()
    action()
}

print("--- 11.4/11.5 trailing ---")
doTwice { print("Раз!") }

func process(_ items: [Int], using transform: (Int) -> Int) -> [Int] {
    var result: [Int] = []
    for item in items {
        result.append(transform(item))
    }
    return result
}

let nums = [1, 2, 3, 4]
print("doubled:", process(nums) { $0 * 2 })
print("squared:", process(nums) { $0 * $0 })

// MARK: - 11.6 Multiple trailing closures

func loadData(
    onSuccess: (String) -> Void,
    onError: (Error) -> Void
) {
    onSuccess("ok")
}

print("--- 11.6 multiple trailing ---")
loadData { result in
    print("успех:", result)
} onError: { error in
    print("ошибка:", error)
}

// MARK: - 11.7 $0, $1

let prices = [600, 1200, 1100, 1400, 200]
print("--- 11.7 $0, $1 ---")
print("withVAT:", prices.map { $0 * 112 / 100 })
print("expensive:", prices.filter { $0 > 1000 })
print("total:", prices.reduce(0, +))
print("sorted asc:", prices.sorted { $0 < $1 })

// MARK: - 11.8 typealias

typealias Completion = (Result<Void, Error>) -> Void
typealias DataLoader = (String) -> [String]

func saveData(_ data: String, completion: @escaping Completion) {
    completion(.success(()))
}

func loadAll(using loader: DataLoader) -> [String] {
    return loader("manifest")
}

print("--- 11.8 typealias ---")
saveData("hello") { _ in print("Saved") }
print("loadAll:", loadAll(using: { _ in ["a", "b", "c"] }))

// MARK: - 11.10 Closure это reference type

var counter = 0
let action1 = {
    counter += 1
    print("counter:", counter)
}
let action2 = action1   // та же closure

print("--- 11.10 reference ---")
action1()        // 1
action2()        // 2

// MARK: - 11.11 Захват переменной

var x = 10
let printX = { print("printX:", x) }
printX()         // 10

x = 99
printX()         // 99 — увидели новое значение

// makeCounter
func makeCounter() -> () -> Int {
    var count = 0
    let counter = {
        count += 1
        return count
    }
    return counter
}

print("--- 11.11 makeCounter ---")
let c1 = makeCounter()
let c2 = makeCounter()
print("c1:", c1())     // 1
print("c1:", c1())     // 2
print("c2:", c2())     // 1
print("c1:", c1())     // 3

// MARK: - 11.12 Capture list

class Counter {
    var n = 0

    func snapshot() -> () -> Int {
        return { [n = self.n] in n }    // снимок n в момент создания
    }
}

print("--- 11.12 capture by value ---")
let cnt = Counter()
cnt.n = 5
let snap = cnt.snapshot()
cnt.n = 100
print("snap:", snap())     // 5 — не изменилось
print("cnt.n:", cnt.n)     // 100

// MARK: - 11.14 @escaping

class HomeViewModel {
    var onUpdate: (() -> Void)?

    func setOnUpdate(_ closure: @escaping () -> Void) {
        self.onUpdate = closure
    }
}

print("--- 11.14 @escaping ---")
let vmEsc = HomeViewModel()
vmEsc.setOnUpdate { print("update!") }
vmEsc.onUpdate?()

// MARK: - 11.15 Retain cycle (без weak)

class CartLeaky {
    var onChange: (() -> Void)?
    let id = UUID().uuidString.prefix(8)

    func setup() {
        onChange = {
            print("CartLeaky \(self.id) onChange")
        }
    }

    deinit {
        print("CartLeaky \(self.id) deinit")
    }
}

print("--- 11.15 retain cycle ---")
do {
    let cart = CartLeaky()
    cart.setup()
    print("created cart, id:", cart.id)
}
// deinit НЕ напечатается — retain cycle через self в onChange

// MARK: - 11.16 Починка через [weak self]

class CartFixed {
    var onChange: (() -> Void)?
    let id = UUID().uuidString.prefix(8)

    func setup() {
        onChange = { [weak self] in
            guard let self else { return }
            print("CartFixed \(self.id) onChange")
        }
    }

    deinit {
        print("CartFixed \(self.id) deinit")
    }
}

print("--- 11.16 [weak self] ---")
do {
    let cart = CartFixed()
    cart.setup()
    print("created cart, id:", cart.id)
}
// deinit ДОЛЖЕН напечататься

// MARK: - 11.19 Result

enum LoginError: Error {
    case wrongPassword
    case userBlocked
}

func login(password: String) -> Result<String, LoginError> {
    if password == "secret" {
        return .success("token-abc-123")
    } else {
        return .failure(.wrongPassword)
    }
}

print("--- 11.19 Result ---")
let r1 = login(password: "secret")
let r2 = login(password: "wrong")

for r in [r1, r2] {
    switch r {
    case .success(let token):
        print("OK:", token)
    case .failure(let error):
        print("Fail:", error)
    }
}

// MARK: - 11.20 async/await preview

func loadProductsAsync() async -> [String] {
    return ["Латте", "Раф", "Капучино"]
}

print("--- 11.20 async/await ---")
// В Swift 6 верхний уровень скрипта уже асинхронный: пишем await напрямую.
// Ждать Task через DispatchGroup.wait() нельзя — главный поток
// заблокируется, а Task на него не попадёт (дедлок).
let products = await loadProductsAsync()
print("async result:", products)

// MARK: - Большое упражнение 11.4

func transformAll(_ items: [String], using transform: (String) -> String) -> [String] {
    var result: [String] = []
    for item in items {
        result.append(transform(item))
    }
    return result
}

let names = ["Айгерим", "Бауыржан", "Динара"]
print("--- 11.4 transformAll ---")
print(transformAll(names) { $0.uppercased() })
print(transformAll(names) { "Сәлем, \($0)!" })

// MARK: - 11.6 Цепочка

let pricesEx = [600, 1200, 1100, 1400, 250, 800]
let withVAT = pricesEx
    .map { $0 * 112 / 100 }
    .filter { $0 > 1000 }
let totalVAT = withVAT.reduce(0, +)
print("--- 11.6 чейн ---")
print("withVAT:", withVAT)
print("totalVAT:", totalVAT)

// MARK: - 11.7 applyTwice generic

func applyTwice<T>(_ value: T, _ transform: (T) -> T) -> T {
    return transform(transform(value))
}

print("--- 11.7 applyTwice ---")
print("applyTwice(5, *2):", applyTwice(5) { $0 * 2 })
print("applyTwice('ха', $0+$0):", applyTwice("ха") { $0 + $0 })
print("applyTwice([1,2], +):", applyTwice([1, 2]) { $0 + $0 })
