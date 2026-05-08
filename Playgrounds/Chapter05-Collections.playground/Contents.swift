import Foundation

// MARK: - 5.1 Array — упорядоченный список

let names = ["Айгерим", "Бауыржан", "Динара"]
let prices = [600, 1200, 1100, 1400]
let weights = [50.5, 65.3, 80.0]
let flags = [true, false, true]

print("--- 5.1 Array ---")
print(names)
print(prices)

// MARK: - 5.2 Доступ через индекс

print("--- 5.2 Доступ ---")
print("first:", names[0])
print("second:", names[1])
print("third:", names[2])
// names[5] — crash, не запускаем

// MARK: - 5.3 .first, .last, .count, .isEmpty

print("--- 5.3 .first, .last ---")
print("first:", names.first ?? "nil")
print("last:", names.last ?? "nil")
print("count:", names.count)
print("isEmpty:", names.isEmpty)

let empty: [String] = []
print("empty.first:", empty.first ?? "nil")
print("empty.isEmpty:", empty.isEmpty)

// MARK: - 5.4 Изменение

print("--- 5.4 Изменение ---")
var cart: [String] = []
cart.append("хлеб")
cart.append("молоко")
cart.append("сыр")
cart.insert("яблоки", at: 0)
print("после insert:", cart)
cart.remove(at: 2)
print("после remove(at: 2):", cart)
cart[0] = "груши"
print("после замены [0]:", cart)

// MARK: - 5.5 Value semantics

print("--- 5.5 Value semantics ---")
var a = [1, 2, 3]
var b = a            // копия (CoW под капотом)
b.append(4)
print("a:", a)        // [1, 2, 3]
print("b:", b)        // [1, 2, 3, 4]

func addOne(to numbers: [Int]) -> [Int] {
    var result = numbers
    result.append(0)
    return result
}
let original = [1, 2, 3]
let modified = addOne(to: original)
print("original:", original)
print("modified:", modified)

// MARK: - 5.6 Конструкторы

print("--- 5.6 Конструкторы ---")
let zeros = Array(repeating: 0, count: 5)
let dashes = Array(repeating: "-", count: 10)
print("zeros:", zeros)
print("dashes:", dashes)
let oneToTen = Array(1...10)
print("Array(1...10):", oneToTen)
let chars = Array("Сәлем")
print("Array string:", chars)

// MARK: - 5.7 sort vs sorted

print("--- 5.7 sort vs sorted ---")
let nums = [3, 1, 4, 1, 5, 9, 2, 6]
let asc = nums.sorted()
let desc = nums.sorted(by: >)
print("asc:", asc)
print("desc:", desc)
print("nums (не изменился):", nums)

var nums2 = [3, 1, 4, 1, 5, 9, 2, 6]
nums2.sort()
print("nums2 после sort():", nums2)

struct Product {
    let name: String
    let price: Int
}

let products = [
    Product(name: "Раф", price: 1400),
    Product(name: "Латте", price: 1200),
    Product(name: "Эспрессо", price: 600)
]

let byPriceAsc = products.sorted(by: { $0.price < $1.price })
print("byPriceAsc:", byPriceAsc.map { "\($0.name) \($0.price)" })

// MARK: - 5.8 reverse vs reversed (ловушка)

print("--- 5.8 reverse vs reversed ---")
let arr = [1, 2, 3]
let rev = arr.reversed()
print("reversed type:", type(of: rev))     // ReversedCollection<[Int]>
print("rev as array:", Array(rev))

// MARK: - 5.9 Slicing — ArraySlice

print("--- 5.9 Slicing ---")
let bigNums = [10, 20, 30, 40, 50]
let middle = bigNums[1...3]
print("type:", type(of: middle))            // ArraySlice<Int>
print("count:", middle.count)
print("middle[1]:", middle[1])              // 20 — индексы оригинальные!
let middleArr = Array(middle)
print("middleArr[0]:", middleArr[0])        // 20 — теперь обычный

// MARK: - 5.10 map

print("--- 5.10 map ---")
let coffeePrices = [600, 1200, 1100, 1400]
let withVAT = coffeePrices.map { $0 * 112 / 100 }
print("withVAT:", withVAT)

let labels = coffeePrices.map { "\($0) ₸" }
print("labels:", labels)

let kgs = [1, 2, 5, 10]
let kgLabels = kgs.map { "\($0) кг" }
print("kgLabels:", kgLabels)

// MARK: - 5.11 filter

print("--- 5.11 filter ---")
let expensive = coffeePrices.filter { $0 > 1000 }
print("expensive:", expensive)

let allNums = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
let evens = allNums.filter { $0 % 2 == 0 }
print("evens:", evens)

// цепочка map + filter
let bigWithVAT = coffeePrices
    .map { $0 * 112 / 100 }
    .filter { $0 > 1300 }
print("bigWithVAT:", bigWithVAT)

// MARK: - 5.12 reduce

print("--- 5.12 reduce ---")
let total = coffeePrices.reduce(0, +)
print("total:", total)

let words = ["Сәлем", " ", "Алматы"]
let sentence = words.reduce("", +)
print("sentence:", sentence)

let factorial = [2, 3, 4, 5].reduce(1, *)
print("5! =", factorial)

// reduce(into:_:)
let categorized = coffeePrices.reduce(into: [String: [Int]]()) { dict, price in
    let key = price > 1000 ? "дорогие" : "дешёвые"
    dict[key, default: []].append(price)
}
print("categorized:", categorized)

// MARK: - 5.13 forEach

print("--- 5.13 forEach ---")
names.forEach { name in
    print("Сәлем, \(name)!")
}

// MARK: - 5.14 compactMap

print("--- 5.14 compactMap ---")
let inputs = ["42", "abc", "100", "что-то", "5"]
let parsedAsOpt = inputs.map { Int($0) }
print("map:", parsedAsOpt)
let parsed = inputs.compactMap { Int($0) }
print("compactMap:", parsed)

// MARK: - 5.15 flatMap

print("--- 5.15 flatMap ---")
let nested = [[1, 2, 3], [4, 5], [6, 7, 8, 9]]
let flat = nested.flatMap { $0 }
print("flat:", flat)

struct Order { let items: [String] }
let orders1 = [
    Order(items: ["Латте", "Раф"]),
    Order(items: ["Эспрессо"]),
    Order(items: ["Капучино", "Латте", "Раф"])
]
let allItems = orders1.flatMap { $0.items }
print("allItems:", allItems)

// MARK: - 5.16 Поиск

print("--- 5.16 Поиск ---")
let pricesSearch = [200, 1500, 800, 3200, 950]
print("first(where: > 1000):", pricesSearch.first(where: { $0 > 1000 }) ?? -1)
print("firstIndex(where: > 1000):", pricesSearch.firstIndex(where: { $0 > 1000 }) ?? -1)
print("contains 1500:", pricesSearch.contains(1500))
print("contains > 3000:", pricesSearch.contains(where: { $0 > 3000 }))
print("contains < 100:", pricesSearch.contains(where: { $0 < 100 }))
print("allSatisfy >= 100:", pricesSearch.allSatisfy { $0 >= 100 })
print("allSatisfy >= 1000:", pricesSearch.allSatisfy { $0 >= 1000 })

// MARK: - 5.17 min, max, и компараторы

print("--- 5.17 min, max ---")
let scores = [85, 72, 90, 65, 78, 95]
print("min:", scores.min() ?? -1)
print("max:", scores.max() ?? -1)

let cheapest = products.min(by: { $0.price < $1.price })
let mostExpensive = products.max(by: { $0.price < $1.price })
print("cheapest:", cheapest?.name ?? "nil")
print("mostExpensive:", mostExpensive?.name ?? "nil")

// MARK: - 5.18 Dictionary

print("--- 5.18 Dictionary ---")
let phoneBook = [
    "Айгерим": "+7 701 123",
    "Бауыржан": "+7 705 555",
    "Динара": "+7 707 999"
]
print("Айгерим:", phoneBook["Айгерим"] ?? "nil")
print("Болат:", phoneBook["Болат"] ?? "nil")

let counts: [String: Int] = ["яблоки": 3, "груши": 1]
print("яблоки default 0:", counts["яблоки", default: 0])
print("бананы default 0:", counts["бананы", default: 0])

var orderItems: [String: Int] = [:]
orderItems["Латте", default: 0] += 1
orderItems["Латте", default: 0] += 1
orderItems["Капучино", default: 0] += 1
print("orderItems:", orderItems)

// MARK: - 5.19 Удаление ключа

print("--- 5.19 Удаление ---")
var ages: [String: Int] = ["Айгерим": 25, "Бауыржан": 30]
ages["Бауыржан"] = nil
print("после nil:", ages)

// MARK: - 5.20 Перебор словаря и Dictionary(grouping:by:)

print("--- 5.20 Перебор + grouping ---")
let menu = [
    "Латте": 1200,
    "Капучино": 1100,
    "Эспрессо": 600
]
for (item, price) in menu.sorted(by: { $0.key < $1.key }) {
    print("\(item) — \(price) ₸")
}

let purchases = ["Латте", "Капучино", "Латте", "Эспрессо", "Капучино", "Латте"]
let purchaseCounts = Dictionary(grouping: purchases, by: { $0 })
    .mapValues { $0.count }
print("purchaseCounts:", purchaseCounts)

// MARK: - 5.21 Set

print("--- 5.21 Set ---")
let tags: Set<String> = ["swift", "ios", "swift", "uikit"]
print("tags:", tags, "count:", tags.count)

var allowedColors: Set<String> = ["red", "green", "blue"]
allowedColors.insert("yellow")
print("contains green:", allowedColors.contains("green"))
allowedColors.remove("red")
print("after remove red:", allowedColors)

// MARK: - 5.22 Set операции

print("--- 5.22 Set операции ---")
let coffee: Set = ["Латте", "Капучино", "Раф", "Эспрессо"]
let popular: Set = ["Латте", "Капучино", "Чай"]

print("union:", coffee.union(popular).sorted())
print("intersection:", coffee.intersection(popular).sorted())
print("subtracting:", coffee.subtracting(popular).sorted())
print("symmetricDifference:", coffee.symmetricDifference(popular).sorted())

let small: Set = ["a", "b"]
let big: Set = ["a", "b", "c", "d"]
print("small isSubset:", small.isSubset(of: big))
print("big isSuperset:", big.isSuperset(of: small))

// MARK: - 5.23 Hashable

print("--- 5.23 Hashable ---")
struct ProductH: Hashable {
    let id: Int
    let name: String
}
var stockSet: Set<ProductH> = []
stockSet.insert(ProductH(id: 1, name: "Латте"))
stockSet.insert(ProductH(id: 1, name: "Латте"))    // дубль не добавится
stockSet.insert(ProductH(id: 2, name: "Раф"))
print("stockSet count:", stockSet.count)            // 2

// MARK: - 5.24 String как Collection

print("--- 5.24 String ---")
let greeting = "Сәлем"
for char in greeting {
    print(char, terminator: " ")
}
print()
print("count:", greeting.count)

let upper = greeting.uppercased()
print("upper:", upper)
let firstTwo = greeting.prefix(2)
let lastTwo = greeting.suffix(2)
print("prefix:", firstTwo, "suffix:", lastTwo)

// MARK: - Большое упражнение 5.8: магазин ShopApp

print("--- 5.8 ShopApp итоги дня ---")

struct OrderItem {
    let product: String
    let category: String
    let price: Int
    let quantity: Int
}

let bigOrders: [OrderItem] = [
    OrderItem(product: "Латте", category: "напитки", price: 1200, quantity: 3),
    OrderItem(product: "Эспрессо", category: "напитки", price: 600, quantity: 5),
    OrderItem(product: "Чизкейк", category: "десерты", price: 2500, quantity: 2),
    OrderItem(product: "Раф", category: "напитки", price: 1400, quantity: 4),
    OrderItem(product: "Тирамису", category: "десерты", price: 2800, quantity: 1),
    OrderItem(product: "Капучино", category: "напитки", price: 1100, quantity: 6)
]

// 1. Общая выручка
let revenue = bigOrders.reduce(0) { acc, item in
    acc + item.price * item.quantity
}
print("Выручка:", revenue, "₸")

// 2. Средний чек
let avg = Double(revenue) / Double(bigOrders.count)
print("Средний чек:", avg.formatted(.number.precision(.fractionLength(2))), "₸")

// 3. Топ-3
let top3 = bigOrders
    .sorted(by: { $0.price > $1.price })
    .prefix(3)
    .map { $0.product }
print("Топ-3:", top3)

// 4. Названия напитков
let drinks = bigOrders
    .filter { $0.category == "напитки" }
    .map { $0.product }
print("Напитки:", drinks)

// 5. Уникальные категории
let categories = Set(bigOrders.map { $0.category })
print("Категорий:", categories.count)

// 6. Группировка
let byCategory = Dictionary(grouping: bigOrders, by: { $0.category })
    .mapValues { items in
        items.reduce(0) { acc, item in acc + item.price * item.quantity }
    }
print("По категориям:", byCategory)
