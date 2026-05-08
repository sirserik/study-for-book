import Foundation
import Observation

// MARK: - 9.1 Метод

class Greeter {
    let name: String
    init(name: String) { self.name = name }
    func sayHello() {
        print("Сәлем, \(name)!")
    }
}

let g = Greeter(name: "Айгерим")
g.sayHello()

// MARK: - 9.2 Метод с параметрами

class Calculator {
    var lastResult: Int = 0
    func add(_ a: Int, _ b: Int) -> Int {
        let sum = a + b
        lastResult = sum
        return sum
    }
}

let c = Calculator()
let r = c.add(3, 4)
print("--- 9.2 Calculator ---")
print("add(3, 4) =", r)
print("lastResult:", c.lastResult)

// MARK: - 9.3 Stored vs computed

class PersonAge {
    var age: Int
    init(age: Int) { self.age = age }
    var birthYear: Int {
        let cur = Calendar.current.component(.year, from: .now)
        return cur - age
    }
}

print("--- 9.3 Stored vs computed ---")
let pp = PersonAge(age: 30)
print("birthYear:", pp.birthYear)
pp.age = 31
print("birthYear после age=31:", pp.birthYear)

struct Rectangle {
    let width: Double
    let height: Double
    var area: Double { return width * height }
    var perimeter: Double { return 2 * (width + height) }
}

let rect = Rectangle(width: 3, height: 4)
print("Rectangle 3×4: area =", rect.area, "perimeter =", rect.perimeter)

// MARK: - 9.4 Computed setter

struct Temperature {
    var celsius: Double

    var fahrenheit: Double {
        get { return celsius * 9 / 5 + 32 }
        set { celsius = (newValue - 32) * 5 / 9 }
    }
}

print("--- 9.4 Setter ---")
var t = Temperature(celsius: 0)
print("0°C =", t.fahrenheit, "°F")
t.fahrenheit = 100
print("100°F =", t.celsius, "°C")

// MARK: - 9.5 willSet / didSet

class StepCounter {
    var totalSteps: Int = 0 {
        willSet(newSteps) {
            print("Сейчас будет \(newSteps) шагов")
        }
        didSet {
            if totalSteps > oldValue {
                print("Добавили \(totalSteps - oldValue) шагов")
            }
        }
    }
}

print("--- 9.5 willSet/didSet ---")
let counter = StepCounter()
counter.totalSteps = 100
counter.totalSteps = 250

// MARK: - 9.6 lazy var

class DataLoader {
    let path: String

    lazy var content: String = {
        print("Читаю файл \(path)...")
        return "содержимое файла"
    }()

    init(path: String) {
        self.path = path
    }
}

print("--- 9.6 lazy var ---")
let loader = DataLoader(path: "/data.txt")
print("создал loader, файл ещё не читался")
print(loader.content)        // тут читается
print(loader.content)        // уже не читается, кэш

// MARK: - 9.7 static / singleton

struct AppConfig {
    static let baseURL = "https://api.shop.example.kz"
    static let timeoutSeconds = 30
    static let supportedCurrencies = ["KZT", "USD", "RUB"]

    static func makeURL(for path: String) -> URL? {
        return URL(string: "\(baseURL)\(path)")
    }
}

print("--- 9.7 static ---")
print("baseURL:", AppConfig.baseURL)
print("makeURL:", AppConfig.makeURL(for: "/products") ?? "nil")

final class AppLogger {
    static let shared = AppLogger()
    private init() {}

    func log(_ message: String) {
        print("[\(Date())] \(message)")
    }
}

AppLogger.shared.log("первое сообщение")
AppLogger.shared.log("ещё одно")

// MARK: - 9.8 subscript

struct WeekDays {
    let days = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    subscript(index: Int) -> String {
        return days[index]
    }
}

print("--- 9.8 subscript ---")
let w = WeekDays()
print("week[0] =", w[0])
print("week[5] =", w[5])

struct Cache {
    private var storage: [String: Int] = [:]
    subscript(key: String) -> Int? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
}

var cache = Cache()
cache["визитов"] = 1
cache["визитов"] = (cache["визитов"] ?? 0) + 1
print("Cache визитов:", cache["визитов"] ?? -1)

// MARK: - 9.10 @MainActor

@MainActor
final class HomeViewModel {
    var products: [String] = []

    func reload() {
        products = ["Латте", "Капучино", "Раф"]
    }
}

// MARK: - 9.11 @Observable

@Observable
@MainActor
final class HomeObservableViewModel {
    var products: [String] = []
    var isLoading: Bool = false
}

// @MainActor-классы используем из MainActor контекста — Swift 6 не пропустит
// обращение из top-level (это та самая статическая проверка, про которую речь в главе).
// MainActor.assumeIsolated утверждает, что мы УЖЕ на main thread, и даёт обращаться
// к @MainActor-объектам синхронно. В скриптах это работает, потому что код
// командной строки выполняется на main.
MainActor.assumeIsolated {
    print("--- 9.10 @MainActor ---")
    let vm = HomeViewModel()
    vm.reload()
    print("products:", vm.products)

    print("--- 9.11 @Observable ---")
    let ovm = HomeObservableViewModel()
    ovm.products = ["Латте", "Раф"]
    ovm.isLoading = false
    print("@Observable products:", ovm.products)
}

// MARK: - 9.12 Уровни доступа

class BankAccount {
    private var balance: Int = 0
    let owner: String

    init(owner: String) { self.owner = owner }

    func deposit(_ amount: Int) {
        balance += amount
    }

    func withdraw(_ amount: Int) -> Bool {
        if balance < amount { return false }
        balance -= amount
        return true
    }

    func currentBalance() -> Int { return balance }
}

print("--- 9.12 Уровни доступа ---")
let acc = BankAccount(owner: "Айгерим")
acc.deposit(1500)
acc.deposit(500)
_ = acc.withdraw(800)
print("\(acc.owner) баланс: \(acc.currentBalance()) ₸")

// MARK: - 9.13 private(set)

class CounterPrivateSet {
    private(set) var count: Int = 0

    func increment() {
        count += 1
    }
}

print("--- 9.13 private(set) ---")
let cps = CounterPrivateSet()
cps.increment()
cps.increment()
cps.increment()
print("count =", cps.count)
// cps.count = 100   // ❌ Cannot assign to property: 'count' setter is inaccessible

// MARK: - 9.14 init? failable

struct Email {
    let value: String
    init?(_ value: String) {
        guard value.contains("@") else { return nil }
        self.value = value
    }
}

print("--- 9.14 init? ---")
let valid = Email("aidos@example.kz")
let invalid = Email("not_an_email")
print("valid:", valid?.value ?? "nil")
print("invalid:", invalid?.value ?? "nil")

// MARK: - 9.15 mutating

struct CounterMut {
    var n: Int = 0
    mutating func increment() {
        n += 1
    }
}

print("--- 9.15 mutating ---")
var cm = CounterMut()
cm.increment()
cm.increment()
print("CounterMut.n:", cm.n)

// MARK: - Большое упражнение 9.5: ShoppingCart

print("--- 9.5 ShoppingCart ---")

final class ShoppingCart {

    private(set) var items: [String] = [] {
        didSet {
            print("items: было \(oldValue.count), стало \(items.count)")
        }
    }
    private(set) var total: Int = 0
    private(set) var lastItemDate: Date?

    var count: Int { return items.count }

    func add(item: String, price: Int) {
        items.append(item)
        total += price
        lastItemDate = Date()
    }

    func remove(item: String) {
        items.removeAll { $0 == item }
    }

    func clear() {
        items = []
        total = 0
        lastItemDate = nil
    }

    func summary() -> String {
        let totalFormatted = total.formatted(.number)
        let word = count == 1 ? "товар" : "товара"
        return "\(count) \(word) на сумму \(totalFormatted) ₸"
    }
}

let cart = ShoppingCart()
cart.add(item: "Латте", price: 1200)
cart.add(item: "Капучино", price: 1100)
cart.add(item: "Раф", price: 1400)
print(cart.summary())
cart.clear()
print(cart.summary())
