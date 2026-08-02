import Foundation

// MARK: - 8.2 Value vs reference

print("--- 8.2 struct copy ---")
struct PointS {
    var x: Int
    var y: Int
}

var sa = PointS(x: 1, y: 2)
var sb = sa
sb.x = 999
print("sa.x =", sa.x)            // 1
print("sb.x =", sb.x)            // 999

print("--- 8.2 class reference ---")
class Counter {
    var n: Int = 0
}

let ca = Counter()
let cb = ca
cb.n = 999
print("ca.n =", ca.n)            // 999
print("cb.n =", cb.n)            // 999

// MARK: - 8.5 ARC и deinit

print("--- 8.5 ARC и deinit ---")
class FileHandle {
    let path: String

    init(path: String) {
        self.path = path
        print("Открыл файл \(path)")
    }

    deinit {
        print("Закрываю файл \(path)")
    }
}

func work() {
    let handle = FileHandle(path: "/tmp/data.txt")
    print("работаю с \(handle.path)")
    // handle уйдёт из scope здесь
}

work()
// Открыл /tmp/data.txt
// работаю с /tmp/data.txt
// Закрываю /tmp/data.txt

// MARK: - 8.6 Передача в функцию

print("--- 8.6 struct copy в функции ---")
struct Box {
    var content: String
}

func emptyOutS(_ box: Box) {
    var box = box
    box.content = ""
}

var myBox = Box(content: "Книга")
emptyOutS(myBox)
print("myBox.content =", myBox.content)    // "Книга"

// inout
func emptyOutInout(_ box: inout Box) {
    box.content = ""
}
var mutableBox = Box(content: "Книга")
emptyOutInout(&mutableBox)
print("mutableBox через inout =", mutableBox.content)    // ""

print("--- 8.6 class reference в функции ---")
class Bag {
    var content: String = "Книга"
}

func emptyOutC(_ bag: Bag) {
    bag.content = ""
}

let myBag = Bag()
emptyOutC(myBag)
print("myBag.content =", myBag.content)    // ""

// MARK: - 8.9 let для struct vs class

print("--- 8.9 let для struct ---")
struct S {
    var x: Int
}
let s = S(x: 1)
// s.x = 5  // ❌ компиляция: Cannot assign to property 's' is a 'let' constant
print("let s.x =", s.x)            // 1

var s2 = S(x: 1)
s2.x = 5                            // OK
print("var s2.x =", s2.x)          // 5

print("--- 8.9 let для class ---")
class C {
    var x: Int = 0
}
let cls = C()
cls.x = 5                           // OK — ссылка let, поле var
print("let cls.x =", cls.x)        // 5
// cls = C()   // ❌ Cannot assign to value: 'cls' is a 'let' constant

// MARK: - 8.10 mutating

print("--- 8.10 mutating ---")
struct CounterS {
    var n: Int = 0

    mutating func increment() {
        n += 1
    }
}

var cs = CounterS()
cs.increment()
cs.increment()
print("CounterS после двух increment:", cs.n)    // 2

// у класса — без mutating
class CounterC {
    var n: Int = 0
    func increment() {
        n += 1
    }
}

let cc = CounterC()
cc.increment()
cc.increment()
print("CounterC после двух increment:", cc.n)    // 2

// MARK: - 8.11 Identity (===)

print("--- 8.11 === ---")
class User {
    let name: String
    init(name: String) { self.name = name }
}

let a = User(name: "Айдос")
let b = User(name: "Айдос")
let c = a

print("a === b:", a === b)        // false — разные объекты
print("a === c:", a === c)        // true  — c указывает на тот же
print("a !== b:", a !== b)        // true

let ids = Set([ObjectIdentifier(a), ObjectIdentifier(b), ObjectIdentifier(a)])
print("уникальных identity:", ids.count)    // 2

// MARK: - 8.12 Equatable для class руками

print("--- 8.12 Equatable для class ---")
class UserEq: Equatable {
    let name: String
    init(name: String) { self.name = name }

    static func == (lhs: UserEq, rhs: UserEq) -> Bool {
        return lhs.name == rhs.name
    }
}

let ea = UserEq(name: "Айдос")
let eb = UserEq(name: "Айдос")
print("ea == eb (по содержимому):", ea == eb)         // true
print("ea === eb (по identity):", ea === eb)         // false

// MARK: - 8.14 Retain cycle

print("--- 8.14 Retain cycle (без weak) ---")
class Owner {
    let name: String
    var pet: Pet?
    init(name: String) { self.name = name }
    deinit { print("Owner \(name) уничтожен") }
}

class Pet {
    let name: String
    var owner: Owner?
    init(name: String) { self.name = name }
    deinit { print("Pet \(name) уничтожен") }
}

func setupCycle() {
    let alice = Owner(name: "Айгерим")
    let rex = Pet(name: "Рекс")
    alice.pet = rex
    rex.owner = alice
    // выход — но retain cycle не даёт уничтожиться
}
setupCycle()
print("после setupCycle: ничего не уничтожилось (утечка)")

// MARK: - 8.15 Починка через weak

print("--- 8.15 С weak (починка) ---")
class OwnerW {
    let name: String
    var pet: PetW?
    init(name: String) { self.name = name }
    deinit { print("OwnerW \(name) уничтожен") }
}

class PetW {
    let name: String
    weak var owner: OwnerW?    // weak!
    init(name: String) { self.name = name }
    deinit { print("PetW \(name) уничтожен") }
}

func setupWeak() {
    let alice = OwnerW(name: "Айгерим")
    let rex = PetW(name: "Рекс")
    alice.pet = rex
    rex.owner = alice
}
setupWeak()
// Должно напечатать deinit обоих — цикл разорван weak

// MARK: - 8.17 actor preview

print("--- 8.17 actor ---")
actor BankAccount {
    private var balance: Int = 0

    func deposit(_ amount: Int) {
        balance += amount
    }

    func getBalance() -> Int {
        return balance
    }
}

let account = BankAccount()
// await прямо на верхнем уровне скрипта: в Swift 6 так можно, и это
// единственный правильный способ дождаться актора. Блокировать main
// через DispatchGroup.wait() нельзя — получится дедлок.
await account.deposit(500)
await account.deposit(300)
let currentBalance = await account.getBalance()
print("balance:", currentBalance, "₸")            // 800 ₸

// MARK: - 8.13 final class

print("--- 8.13 final class ---")
final class HomeViewModel {
    var products: [String] = []
    func load() {
        products = ["Латте", "Раф"]
    }
}

let vm = HomeViewModel()
vm.load()
print("products:", vm.products)

// final запрещает наследование. Без final другой класс мог бы:
// class SpecialHomeVM: HomeViewModel { ... } — теперь нельзя.

// MARK: - 8.16 Sendable

print("--- 8.16 Sendable ---")
struct ProductSendable: Sendable {
    let id: Int
    let name: String
    let price: Int
}

final class Config: Sendable {
    let baseURL: String
    let timeout: Int
    init(baseURL: String, timeout: Int) {
        self.baseURL = baseURL
        self.timeout = timeout
    }
}

let prod = ProductSendable(id: 1, name: "Латте", price: 1200)
let config = Config(baseURL: "https://shop.example.kz", timeout: 30)

// Можно безопасно передать в Task
Task {
    print("в Task:", prod.name, "за", prod.price, "₸")
    print("config:", config.baseURL)
}

try? await Task.sleep(for: .milliseconds(100))

print("--- Done ---")
