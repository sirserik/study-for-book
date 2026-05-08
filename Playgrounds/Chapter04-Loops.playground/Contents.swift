import Foundation

// MARK: - 4.1 for-in по диапазону

print("--- for-in 1...5 ---")
for i in 1...5 {
    print(i)
}

print("--- for-in 0..<10 ---")
for i in 0..<10 {
    print("Раз \(i)")
}

// MARK: - 4.2 for _ in

print("--- for _ in (Алматы 7 раз) ---")
for _ in 0..<7 {
    print("Алматы")
}

// MARK: - 4.3 stride

print("--- stride(from: 0, to: 100, by: 10) ---")
for i in stride(from: 0, to: 100, by: 10) {
    print(i, terminator: " ")
}
print()

print("--- stride(from: 0, through: 100, by: 10) ---")
for i in stride(from: 0, through: 100, by: 10) {
    print(i, terminator: " ")
}
print()

print("--- stride с дробным шагом 0.25 ---")
for x in stride(from: 0.0, through: 1.0, by: 0.25) {
    print(x, terminator: " ")
}
print()

print("--- stride с отрицательным шагом ---")
for i in stride(from: 10, through: 1, by: -1) {
    print(i, terminator: " ")
}
print()

// MARK: - 4.4 reversed

print("--- (1...10).reversed() ---")
for i in (1...10).reversed() {
    print(i, terminator: " ")
}
print()

let names = ["Айгерим", "Бауыржан", "Динара"]
print("--- names.reversed() ---")
for name in names.reversed() {
    print(name)
}

// MARK: - 4.5 for-in по массиву

print("--- цены ---")
let prices = [600, 1200, 1100, 1400]
for price in prices {
    print("\(price) ₸")
}

// MARK: - 4.6 enumerated

print("--- enumerated names ---")
for (index, name) in names.enumerated() {
    print("\(index): \(name)")
}

print("--- enumerated с +1 ---")
for (i, name) in names.enumerated() {
    print("\(i + 1). \(name)")
}

// MARK: - 4.7 zip

let products = ["Латте", "Капучино", "Раф"]
let pricesZ = [1200, 1100, 1400]
print("--- zip products + prices ---")
for (name, price) in zip(products, pricesZ) {
    print("\(name) — \(price) ₸")
}

// разной длины
let prods4 = ["Латте", "Капучино", "Раф", "Эспрессо"]
let stocks3 = [10, 5, 0]
print("--- zip с разной длиной ---")
for (name, stock) in zip(prods4, stocks3) {
    print("\(name): остаток \(stock) шт.")
}

// MARK: - 4.8 Итерация по словарю

let menu: [String: Int] = [
    "Латте": 1200,
    "Капучино": 1100,
    "Раф": 1400,
    "Эспрессо": 600
]

print("--- словарь без сортировки ---")
for (item, price) in menu {
    print("\(item) — \(price) ₸")
}

print("--- словарь, отсортированный по ключу ---")
for (item, price) in menu.sorted(by: { $0.key < $1.key }) {
    print("\(item) — \(price) ₸")
}

print("--- только ключи ---")
for item in menu.keys.sorted() {
    print(item)
}

// MARK: - 4.9 Императив vs функциональный

print("--- функциональный стиль ---")
let imperativeTotal: Int = {
    var t = 0
    for p in prices { t += p }
    return t
}()
let functionalTotal = prices.reduce(0, +)
print("imperative:", imperativeTotal, "functional:", functionalTotal)

let withVAT = prices.map { $0 * 112 / 100 }
let expensive = prices.filter { $0 > 1000 }
print("withVAT:", withVAT)
print("expensive:", expensive)

// MARK: - 4.10 Аккумулятор-паттерн

print("--- сумма, максимум, среднее ---")
var total = 0
for price in prices {
    total += price
}
print("total =", total)

let numbers = [30, 80, 20, 65, 45, 90]
var maxNumber = numbers[0]
for n in numbers {
    if n > maxNumber {
        maxNumber = n
    }
}
print("max =", maxNumber)
print("max() стандартный:", numbers.max() ?? -1)

var count = 0
for n in numbers {
    if n > 50 {
        count += 1
    }
}
print("> 50:", count, "штук (filter:", numbers.filter { $0 > 50 }.count, ")")

// MARK: - 4.11 while

print("--- while сумма до 1000 ---")
var sumW = 0
var iW = 1
while sumW < 1000 {
    sumW += iW
    iW += 1
}
print("остановились на i =", iW, "sum =", sumW)

// MARK: - 4.12 repeat-while

print("--- repeat-while: бросаем кубик до 6 ---")
var dieRoll: Int
var rolls = 0
repeat {
    dieRoll = Int.random(in: 1...6)
    rolls += 1
} while dieRoll != 6
print("выпало 6 за \(rolls) бросков")

// MARK: - 4.13 break и continue

print("--- break ---")
let nums = [1, 5, 3, 8, 2, 7]
for n in nums {
    if n == 8 {
        print("Нашли 8! Выхожу.")
        break
    }
    print("Проверяю \(n)")
}

print("--- continue (нечётные) ---")
for n in 1...10 {
    if n % 2 == 0 { continue }
    print(n, terminator: " ")
}
print()

// MARK: - 4.14 Вложенные циклы и labeled

print("--- вложенные ---")
for x in 1...3 {
    for y in 1...3 {
        print("(\(x),\(y))", terminator: " ")
    }
    print()
}

print("--- labeled break ---")
let grid = [
    [1, 2, 3],
    [4, 5, 999],
    [7, 8, 9]
]

outer: for row in grid {
    for cell in row {
        if cell == 999 {
            print("Нашли 999, выхожу из обоих циклов")
            break outer
        }
        print(cell, terminator: " ")
    }
}
print()

// MARK: - 4.15 Бесконечный цикл с break

print("--- while true с break ---")
var counter = 0
while true {
    counter += 1
    if counter == 5 { break }
}
print("counter =", counter)

// MARK: - Большое упражнение 4.9 — FizzBuzz

print("--- FizzBuzz императивный ---")
for n in 1...15 {
    if n % 15 == 0 {
        print("FizzBuzz")
    } else if n % 3 == 0 {
        print("Fizz")
    } else if n % 5 == 0 {
        print("Buzz")
    } else {
        print(n)
    }
}

print("--- FizzBuzz функциональный ---")
let lines = (1...15).map { n -> String in
    switch (n % 3 == 0, n % 5 == 0) {
    case (true, true):   "FizzBuzz"
    case (true, false):  "Fizz"
    case (false, true):  "Buzz"
    case (false, false): "\(n)"
    }
}
for line in lines {
    print(line)
}
