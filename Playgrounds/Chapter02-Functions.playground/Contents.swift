import Foundation

// MARK: - 2.1 Зачем нужны функции

func openCafe() {
    print("1. Включить кофемашину")
    print("2. Прогреть 5 минут")
    print("3. Засыпать зерно")
    print("4. Налить молоко")
    print("5. Тестовый эспрессо")
    print("6. Открыть кассу")
}

openCafe()
print("---")

// MARK: - 2.3 Функция с одним параметром

func cookEggs(count: Int) {
    print("Жарю \(count) яиц")
}

cookEggs(count: 1)
cookEggs(count: 3)

// MARK: - 2.4 Несколько параметров

func greet(name: String, age: Int) {
    print("Сәлем, \(name)! Тебе \(age) лет.")
}

greet(name: "Айгерим", age: 25)

// MARK: - 2.5 Возврат значения

func sum(a: Int, b: Int) -> Int {
    return a + b
}

let result = sum(a: 3, b: 4)
print("sum(3,4) =", result)

// Возвраты других типов
func makeGreeting(name: String) -> String {
    return "Сәлем, \(name)!"
}
func isAdult(age: Int) -> Bool {
    return age >= 18
}
func formattedPrice(_ kzt: Int) -> String {
    return "\(kzt) ₸"
}

print(makeGreeting(name: "Айдос"))
print(isAdult(age: 25))
print(formattedPrice(15_000))

// MARK: - 2.6 Tuple-возврат

func divmod(_ a: Int, _ b: Int) -> (quotient: Int, remainder: Int) {
    return (a / b, a % b)
}

let r = divmod(17, 5)
print("17 / 5 =", r.quotient, "ост.", r.remainder)

let (q, rem) = divmod(20, 6)
print("20 / 6 =", q, "ост.", rem)

// Без имён
func minMax(_ a: Int, _ b: Int) -> (Int, Int) {
    return (min(a, b), max(a, b))
}
let pair = minMax(7, 3)
print("min, max:", pair.0, pair.1)

// MARK: - 2.7 Подписи параметров

func greet2(to name: String) {
    print("Сәлем, \(name)!")
}
greet2(to: "Айгерим")

// MARK: - 2.8 Значения по умолчанию

func order(item: String, count: Int = 1, urgent: Bool = false) {
    print("Заказ: \(count) × \(item), срочно: \(urgent)")
}

order(item: "Латте")
order(item: "Капучино", count: 2)
order(item: "Эспрессо", urgent: true)
order(item: "Раф", count: 3, urgent: true)

// MARK: - 2.9 Variadic

func sumAll(_ numbers: Int...) -> Int {
    var total = 0
    for n in numbers {
        total = total + n
    }
    return total
}

print("sumAll(1,2,3) =", sumAll(1, 2, 3))
print("sumAll(10,20,30,40,50) =", sumAll(10, 20, 30, 40, 50))
print("sumAll() =", sumAll())

// MARK: - 2.10 Локальные переменные и scope

func calculateTotal(price: Int, count: Int) -> Int {
    let perItem = price
    let subtotal = perItem * count
    let vat = subtotal * 12 / 100
    return subtotal + vat
}

print("Итого 3 × 1000 ₸ + 12% НДС =", calculateTotal(price: 1000, count: 3))
// print(perItem) // ❌ Cannot find 'perItem' in scope

// MARK: - 2.11 inout

func increment(_ value: inout Int) {
    value = value + 1
}

var counter = 5
increment(&counter)
increment(&counter)
print("counter после двух increment:", counter)

// Generic swap
func swapValues<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

var x = 10
var y = 20
swapValues(&x, &y)
print("after swap: x =", x, "y =", y)

var s1 = "Алматы"
var s2 = "Астана"
swapValues(&s1, &s2)
print("after swap strings:", s1, s2)

// MARK: - 2.12 Функция как значение

func add(_ a: Int, _ b: Int) -> Int { return a + b }

let operation: (Int, Int) -> Int = add
print("operation(3, 4) =", operation(3, 4))

func apply(_ a: Int, _ b: Int, using op: (Int, Int) -> Int) -> Int {
    return op(a, b)
}
print("apply(3, 4, +) =", apply(3, 4, using: +))
print("apply(3, 4, *) =", apply(3, 4, using: *))

// Фабрика функций
func makeAdder(adding number: Int) -> (Int) -> Int {
    return { n in n + number }
}

let plus10 = makeAdder(adding: 10)
let plus100 = makeAdder(adding: 100)
print("plus10(5) =", plus10(5))
print("plus100(5) =", plus100(5))

// applyTwice
func applyTwice(_ value: Int, _ op: (Int) -> Int) -> Int {
    return op(op(value))
}

func double(_ n: Int) -> Int { return n * 2 }
func addOne(_ n: Int) -> Int { return n + 1 }
print("applyTwice(5, double) =", applyTwice(5, double))
print("applyTwice(5, addOne) =", applyTwice(5, addOne))

// MARK: - 2.13 Перегрузка

func describe(_ n: Int) {
    print("Целое число \(n)")
}
func describe(_ d: Double) {
    print("Дробное число \(d)")
}
func describe(_ s: String) {
    print("Строка «\(s)»")
}

describe(42)
describe(3.14)
describe("Алматы")

// MARK: - 2.14 @discardableResult

@discardableResult
func addQuiet(_ a: Int, _ b: Int) -> Int {
    return a + b
}

addQuiet(3, 4)              // нет warning
let totalQuiet = addQuiet(10, 20)
print("addQuiet возвращает:", totalQuiet)

// MARK: - 2.15 throws (intro)

enum MyError: Error {
    case negative
    case tooBig
}

func validateAge(_ age: Int) throws -> Int {
    if age < 0 { throw MyError.negative }
    if age > 150 { throw MyError.tooBig }
    return age
}

do {
    let v = try validateAge(25)
    print("validateAge(25) → OK, valid =", v)
} catch {
    print("Ошибка:", error)
}

do {
    let v = try validateAge(-5)
    print("validateAge(-5) → OK, valid =", v)
} catch {
    print("Ошибка validateAge(-5):", error)
}

// MARK: - 2.16 async (intro)

func fetchProducts() async -> [String] {
    return ["Латте", "Капучино", "Эспрессо"]
}

Task {
    let products = await fetchProducts()
    print("fetchProducts() →", products)
}

// MARK: - Большое упражнение 2.9: чек кофейни «Алматы Coffee»

let menu: [String: Int] = [
    "Эспрессо": 600,
    "Латте": 1_200,
    "Капучино": 1_100,
    "Раф": 1_400
]

func priceForItem(_ name: String) -> Int? {
    return menu[name]
}

func orderTotal(items: [String]) -> (subtotal: Int, vat: Int, total: Int) {
    var subtotal = 0
    for item in items {
        if let price = priceForItem(item) {
            subtotal = subtotal + price
        }
    }
    let vat = Int((Double(subtotal) * 0.12).rounded())
    return (subtotal, vat, subtotal + vat)
}

func printReceipt(items: [String]) {
    let parts = orderTotal(items: items)
    print("Чек на \(items.count) позиции:")
    for item in items {
        if let price = priceForItem(item) {
            print("  \(item): \(price) ₸")
        }
    }
    print("Без НДС: \(parts.subtotal) ₸")
    print("НДС 12%: \(parts.vat) ₸")
    print("Итого:   \(parts.total) ₸")
}

printReceipt(items: ["Латте", "Капучино", "Раф"])

// Подождать, пока async-Task закончится в Playground
Thread.sleep(forTimeInterval: 0.1)
