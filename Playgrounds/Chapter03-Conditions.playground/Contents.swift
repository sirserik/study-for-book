import Foundation

// Примечание: в этом Playground встречаются warnings вида
// "will never be executed". Это нормально — мы используем константы
// (let isRaining = true), и Swift статически видит, что ветка else
// не сработает. В реальном коде эти значения приходили бы из переменных
// или параметров, и warnings бы не было. Для демонстрации синтаксиса
// этот стиль удобнее.

// MARK: - 3.1 if

let isRaining = true
if isRaining {
    print("Возьми зонт")
}

let count = 5
if count > 0 {
    print("есть, count =", count)
}

// MARK: - 3.2 if/else

let isLoggedIn = true
if isLoggedIn {
    print("Сәлем!")
} else {
    print("Войдите")
}

// MARK: - 3.3 Операторы сравнения

let age = 18
if age == 18 { print("Ровно 18") }
if age != 18 { print("Не 18") }
if age >= 18 { print("Совершеннолетний") }

let name = "Айдос"
if name == "Айдос" { print("Сәлем, Айдос!") }

let city = "Алматы"
if city < "Бишкек" { print("Алматы стоит раньше Бишкека") }

// MARK: - 3.4 Сравнение Double — ловушка

let a = 0.1 + 0.2
let b = 0.3
print("0.1 + 0.2 == 0.3:", a == b)            // false

let epsilon = 0.0001
if abs(a - b) < epsilon {
    print("примерно равно")
}

// MARK: - 3.5 Логические операторы и short-circuit

let salary = 30000
let isActive = true
if salary > 0 && isActive {
    print("работающий")
}

let nameKZ = "Айдос"
if nameKZ == "Айдос" || nameKZ == "Алия" {
    print("Сәлем!")
}

let isWindy = false
if !isWindy { print("безветренно") }

// Short-circuit спасает от выхода за границы массива
let arr = [10, 20, 30]
let index = 5
if index < arr.count && arr[index] > 0 {
    print("элемент:", arr[index])
} else {
    print("index", index, "вне массива из", arr.count, "элементов")
}

// MARK: - 3.6 if / else if цепочка

let score = 85
if score >= 90 {
    print("Отлично")
} else if score >= 75 {
    print("Хорошо")
} else if score >= 60 {
    print("Удовлетворительно")
} else {
    print("Плохо")
}

// MARK: - 3.7 Тернарный оператор

let umbrella = isRaining ? "взять" : "не брать"
print("Зонт:", umbrella)

let category = age >= 18 ? "взрослый" : "ребёнок"
print(category)

let countItems = 3
let label = countItems == 1 ? "товар" : "товары"
print(countItems, label)

// MARK: - 3.8 if как выражение (Swift 5.9+)

let grade = if score >= 90 {
    "A"
} else if score >= 75 {
    "B"
} else if score >= 60 {
    "C"
} else {
    "D"
}
print("Оценка:", grade)

// MARK: - 3.9 guard — ранний выход

func greetUser(name: String?) {
    guard let name = name else {
        print("Имя не задано, выходим")
        return
    }
    print("Сәлем, \(name)!")
}

greetUser(name: "Айгерим")
greetUser(name: nil)

// guard с несколькими условиями
func calculateBonus(salary: Int, isActive: Bool, monthsWorked: Int) -> Int {
    guard salary > 0 else { return 0 }
    guard isActive else { return 0 }
    guard monthsWorked >= 6 else { return 0 }
    return salary / 10
}

print("Бонус (50 000, true, 12):", calculateBonus(salary: 50_000, isActive: true, monthsWorked: 12))
print("Бонус (50 000, false, 12):", calculateBonus(salary: 50_000, isActive: false, monthsWorked: 12))
print("Бонус (50 000, true, 3):", calculateBonus(salary: 50_000, isActive: true, monthsWorked: 3))

// MARK: - 3.10 switch

let light = "yellow"
switch light {
case "green":
    print("Иди")
case "yellow":
    print("Приготовься")
case "red":
    print("Стой")
default:
    print("Светофор сломан")
}

// несколько значений в одном case
switch light {
case "green", "yellow":
    print("Двигайся")
case "red":
    print("Стой")
default:
    print("Поломка")
}

// статус заказа
let orderStatus = "shipped"
switch orderStatus {
case "pending":   print("Ожидает обработки")
case "confirmed": print("Подтверждён")
case "shipped":   print("В пути")
case "delivered": print("Доставлен")
case "cancelled": print("Отменён")
default:          print("Неизвестный статус")
}

// MARK: - 3.11 Диапазоны и partial range

let scoreInt = 85
switch scoreInt {
case 90...100: print("Отлично")
case 75..<90:  print("Хорошо")
case 60..<75:  print("Удовл.")
case 0..<60:   print("Плохо")
default:       print("Невозможный балл")
}

// partial range
let yearsOld = 70
switch yearsOld {
case ..<7:      print("Дошкольный")
case 7...17:    print("Школьный")
case 18...64:   print("Взрослый")
case 65...:     print("Пенсионный")
default:        print("Невозможно")
}

// MARK: - 3.12 Pattern matching: where, кортежи, case let

let userAge = 25
let isStudent = true

switch userAge {
case 0..<18:
    print("Несовершеннолетний")
case 18...64 where isStudent:
    print("Взрослый, студент — скидка")
case 18...64:
    print("Взрослый")
default:
    print("Пенсионер")
}

// кортежи
let point = (x: 0, y: 5)
switch point {
case (0, 0):
    print("В начале координат")
case (_, 0):
    print("На оси X")
case (0, _):
    print("На оси Y")
case (let x, let y) where x == y:
    print("На диагонали, x == y == \(x)")
default:
    print("Где-то ещё: \(point)")
}

// case let
let response = (statusCode: 200, body: "OK")
switch response {
case (200, let body):
    print("Успех: \(body)")
case (404, _):
    print("Не найдено")
case (let code, _) where code >= 500:
    print("Ошибка сервера: \(code)")
case (let code, _):
    print("Другой код: \(code)")
}

// MARK: - 3.13 switch как выражение (Swift 5.9+)

let status = "shipped"
let labelStatus = switch status {
case "pending":   "Ожидает"
case "confirmed": "Подтверждён"
case "shipped":   "В пути"
case "delivered": "Доставлен"
case "cancelled": "Отменён"
default:          "Неизвестно"
}
print("Лейбл:", labelStatus)

// MARK: - 3.14 fallthrough

func describe(_ n: Int) {
    switch n {
    case 1:
        print("один")
    case 5:
        print("пять")
        fallthrough
    case 10:
        print("много")
    default:
        print("другое")
    }
}

print("---fallthrough demo---")
describe(1)         // один
describe(5)         // пять, потом много (fallthrough)
describe(10)        // много
describe(42)        // другое

// MARK: - Большое упражнение 3.9: bookFee

func bookFeeIf(years: Int) -> Int {
    if years < 7 {
        return 0
    } else if years < 18 {
        return 500
    } else if years < 65 {
        return 1500
    } else {
        return 750
    }
}

func bookFeeSwitch(years: Int) -> Int {
    switch years {
    case ..<7:    return 0
    case 7...17:  return 500
    case 18...64: return 1500
    default:      return 750
    }
}

func bookFeeExpr(years: Int) -> Int {
    return switch years {
    case ..<7:    0
    case 7...17:  500
    case 18...64: 1500
    default:      750
    }
}

print("---bookFee tests---")
for y in [5, 10, 30, 70] {
    let a = bookFeeIf(years: y)
    let b = bookFeeSwitch(years: y)
    let c = bookFeeExpr(years: y)
    print("\(y) лет: if=\(a) ₸, switch=\(b) ₸, expr=\(c) ₸")
}
