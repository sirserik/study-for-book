import Foundation

// MARK: - 1.1 Значение и переменная

let temperature = 12
let city = "Алматы"
let isRaining = true

// MARK: - 1.2 let и var

var counter = 0
counter = counter + 1
counter = counter + 1
print("counter после двух +1:", counter)

// Раскомментируй и посмотри ошибку:
// let constant = 100
// constant = 200    // ❌ Cannot assign to value: 'constant' is a 'let' constant

// MARK: - 1.4 Печать

print(temperature)
print(city, temperature)

let pricePerKg = 950
let weight = 3
let total = pricePerKg * weight
print("Итог:", total, "тенге")

// MARK: - 1.5 Типы

let a = 7
print("type(of: a):", type(of: a))

let b = 7.5
print("type(of: b):", type(of: b))

let c = "7"
print("type(of: c):", type(of: c))

let d = true
print("type(of: d):", type(of: d))

// Явный тип
let priceAsDouble: Double = 5         // 5.0 — Double, потому что мы явно указали
print("priceAsDouble:", priceAsDouble, type(of: priceAsDouble))

// MARK: - 1.6 Int — целые числа

print("Int.min:", Int.min)
print("Int.max:", Int.max)

// Большие числа с разделителями
let million = 1_000_000
let salary = 450_000
let speedOfLight = 299_792_458
print("million == 1000000:", million == 1000000)

// Переполнение
// let big = Int.max
// let bigger = big + 1   // ❌ программа упадёт во время выполнения

// Перепильный оператор &+
let big = Int.max
let wrapped = big &+ 1
print("Int.max &+ 1 =", wrapped)
print("Int.min       =", Int.min)
print("совпадают:", wrapped == Int.min)

// MARK: - 1.7 Double — дробные числа

let pi = 3.14159
let price = 199.99
let rating = 4.7

// Точность Double — известная ловушка
let result = 0.1 + 0.2
print("0.1 + 0.2 =", result)         // 0.30000000000000004
print("равно ли 0.3:", result == 0.3) // false

// MARK: - 1.10 Арифметика

let x = 5
let y = 3
print("5 / 3 =", x / y)        // 1 — целочисленное деление
print("5 % 3 =", x % y)        // 2 — остаток

let xd = 5.0
let yd = 3.0
print("5.0 / 3.0 =", xd / yd)   // 1.666...

// MARK: - 1.11 Преобразование типов

let n = 5
let asDouble = Double(n)              // 5.0
let asString = String(n)              // "5"
print("Double(5) =", asDouble)
print("String(5) =", asString)

let dValue = 3.7
print("Int(3.7) =", Int(dValue))             // 3 (усечение)
print("Int(3.7.rounded()) =", Int(dValue.rounded()))  // 4 (округление)

let sValue = "42"
let parsed = Int(sValue)
print("Int(\"42\") =", parsed as Any)         // Optional(42)

let bad = Int("abc")
print("Int(\"abc\") =", bad as Any)           // nil

// MARK: - 1.12 Строки и escape

let quoted = "Она сказала: \"Сәлем!\""
print(quoted)

let multiline = """
    Менің Отаным — Қазақстан,
    Жерім, көгім, дарқан болсын.
    """
print(multiline)

// raw-строка
let path = #"C:\Users\Aidos\Downloads"#
print(path)

// MARK: - 1.13 Интерполяция

let name = "Айгерим"
let age = 25
print("Сәлем, \(name)! Тебе \(age) лет.")

let aa = 5
let bb = 3
print("Сумма: \(aa + bb), среднее: \((aa + bb) / 2)")

// MARK: - 1.14 FormatStyle (iOS 15+)

let priceValue = 1234.567
print(priceValue.formatted(.number.precision(.fractionLength(2))))
print(priceValue.formatted(.currency(code: "KZT")))
print(priceValue.formatted(.currency(code: "USD")))

let bigNumber = 1_500_000
print(bigNumber.formatted())                          // с разделителями локали

// MARK: - 1.15 Bool и логические операторы

let isLoggedIn = true
let isAdmin = false

print("!isAdmin       :", !isAdmin)
print("logged && admin:", isLoggedIn && isAdmin)
print("logged || admin:", isLoggedIn || isAdmin)
print("!logged || admin:", !isLoggedIn || isAdmin)

// MARK: - Большое упражнение 1.9: расчёт чека Бауыржана

let pricePerApple = 250
let appleCount = 7
let pricePerBanana = 450
let bananaCount = 3
let vatRate = 0.12

let subtotal = pricePerApple * appleCount + pricePerBanana * bananaCount
let totalDouble = Double(subtotal) * (1 + vatRate)
let totalRounded = Int(totalDouble.rounded())
let itemCount = appleCount + bananaCount

print("Бауыржан купил \(itemCount) единиц товара. Итого: \(totalRounded) ₸ (включая 12% НДС).")
