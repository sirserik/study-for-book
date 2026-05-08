import Foundation

// MARK: - 6.2 Опционал в коде

print("--- 6.2 Объявление ---")
let name: String? = "Айдос"
let middleName: String? = nil
print("name:", name ?? "nil")
print("middleName:", middleName ?? "nil")

// MARK: - 6.3 Optional как enum

print("--- 6.3 Optional<String> ---")
let a: String? = "Айдос"
let b: Optional<String> = "Айдос"
print("a == b:", a == b)

let c: String? = nil
let d: Optional<String> = .none
print("c == d:", c == d)

// MARK: - 6.4 Откуда берутся опционалы

print("--- 6.4 Источники опционалов ---")
let phoneBook = ["Айдос": "+7 701", "Айгерим": "+7 705"]
let aidosPhone = phoneBook["Айдос"]
let bolatPhone = phoneBook["Болат"]
print("Айдос:", aidosPhone ?? "nil")
print("Болат:", bolatPhone ?? "nil")

let userInput = "33"
let age = Int(userInput)
let bad = Int("тридцать три")
print("Int(33):", age ?? -1)
print("Int(тридцать три):", bad ?? -1)

let names: [String] = []
let first = names.first
let actualNames = ["Айгерим", "Бауыржан"]
let firstReal = actualNames.first
print("empty.first:", first ?? "nil")
print("real.first:", firstReal ?? "nil")

// MARK: - 6.6 if let

print("--- 6.6 if let ---")
let phone: String? = "+7 701 123"
if let phoneValue = phone {
    print("Длина:", phoneValue.count)
} else {
    print("Номера нет")
}

// shadowing
if let phone = phone {
    print("phone shadowed:", phone.count)
}

// короткая форма (Swift 5.7+)
if let phone {
    print("short form:", phone.count)
}

// MARK: - 6.7 Multiple binding

print("--- 6.7 Multiple binding ---")
let email: String? = "aidos@example.kz"
let password: String? = "secret123"

if let email, let password {
    print("Регистрирую \(email), длина пароля \(password.count)")
}

// с условиями
if let userEmail = email, userEmail.contains("@"),
   let userPassword = password, userPassword.count >= 8 {
    print("Валидно")
}

// MARK: - 6.8 guard let

print("--- 6.8 guard let ---")
func greet(name: String?) {
    guard let name else {
        print("Имени нет")
        return
    }
    print("Сәлем, \(name)!")
}

greet(name: "Айгерим")
greet(name: nil)

func register(email: String?, password: String?) {
    guard let email, let password else { return }
    print("Регистрация \(email), длина \(password.count)")
}
register(email: "aidos@example.kz", password: "12345678")
register(email: nil, password: "12345678")

// MARK: - 6.9 ?? nil-coalescing

print("--- 6.9 ?? ---")
let savedName: String? = nil
let displayName = savedName ?? "Гость"
print("displayName:", displayName)

let userInput2: String? = "Айдос"
let nm = userInput2 ?? "Гость"
print("name:", nm)

let firstName: String? = nil
let lastName: String? = "Серикулы"
let fullName = "\(firstName ?? "") \(lastName ?? "")"
print("fullName:", fullName)

// цепочка
let a1: String? = nil
let a2: String? = nil
let a3 = a1 ?? a2 ?? "Аноним"
print("chain:", a3)

// MARK: - 6.10 ?. Optional chaining

print("--- 6.10 ?. ---")
let userName: String? = "Айдос"
let upperName = userName?.uppercased()
print("upperName:", upperName ?? "nil")

let nilName: String? = nil
let upperNil = nilName?.uppercased()
print("upperNil:", upperNil ?? "nil")

// цепочка
struct Address {
    let city: String
    let street: String
}
struct UserChain {
    let nm: String
    let addr: Address?
}

let user1 = UserChain(nm: "Айдос", addr: Address(city: "Алматы", street: "Толе би"))
let user2 = UserChain(nm: "Бауыржан", addr: nil)

print("user1.city:", user1.addr?.city ?? "nil")
print("user2.city:", user2.addr?.city ?? "nil")

// MARK: - 6.11 ! force unwrap

print("--- 6.11 ! ---")
let p: String? = "+7 701"
print("p!.count =", p!.count)
// nil!.count — крэш, не запускаем

// валидный URL — оправданный case
let url = URL(string: "https://shop.example.kz")!
print("url:", url.absoluteString)

// MARK: - 6.13 switch over Optional

print("--- 6.13 switch over Optional ---")
let phoneSw: String? = "+7 701 123"
switch phoneSw {
case .some(let value):
    print("Есть:", value)
case .none:
    print("Нет")
}

// двойной опционал
let nestedOptional: String?? = nil
switch nestedOptional {
case .some(.some(let value)):
    print("значение:", value)
case .some(.none):
    print("внешний есть, внутри nil")
case .none:
    print("внешний nil")
}

// MARK: - 6.14 Optional.map / flatMap

print("--- 6.14 map / flatMap ---")
let n1: String? = "Айдос"
let upper1 = n1.map { $0.uppercased() }
print("map:", upper1 ?? "nil")

let nNil: String? = nil
let upperNil2 = nNil.map { $0.uppercased() }
print("map nil:", upperNil2 ?? "nil")

// flatMap
let str: String? = "42"
let parsed = str.flatMap { Int($0) }
print("flatMap parse:", parsed ?? -1)

let str2: String? = "abc"
let parsed2 = str2.flatMap { Int($0) }
print("flatMap abc:", parsed2 ?? -1)

// MARK: - 6.15 try?

print("--- 6.15 try? ---")
enum NumberError: Error {
    case empty
    case notANumber
}

func parse(_ s: String) throws -> Int {
    if s.isEmpty { throw NumberError.empty }
    guard let n = Int(s) else { throw NumberError.notANumber }
    return n
}

let v1 = try? parse("42")
let v2 = try? parse("abc")
let v3 = try? parse("")
print("try? parse 42:", v1 ?? -1)
print("try? parse abc:", v2 ?? -1)
print("try? parse '':", v3 ?? -1)

// MARK: - 6.16 as?

print("--- 6.16 as? ---")
let any1: Any = "Алматы"
let asString = any1 as? String
let asInt = any1 as? Int
print("as String:", asString ?? "nil")
print("as Int:", asInt ?? -1)

// MARK: - 6.17 Result

print("--- 6.17 Result ---")
enum LoginError: Error {
    case wrongPassword
    case userBlocked
}

func login(email: String, password: String) -> Result<String, LoginError> {
    if password == "secret" {
        return .success("token-abc-123")
    } else {
        return .failure(.wrongPassword)
    }
}

let r1 = login(email: "aidos@example.kz", password: "secret")
let r2 = login(email: "aidos@example.kz", password: "wrong")

for r in [r1, r2] {
    switch r {
    case .success(let token):
        print("OK:", token)
    case .failure(let error):
        print("Fail:", error)
    }
}

// MARK: - 6.18 Опционал как параметр и результат

print("--- 6.18 Function returns Optional ---")
func findUserName(byId id: Int) -> String? {
    let users = [1: "Айгерим", 2: "Бауыржан"]
    return users[id]
}

print("id=1:", findUserName(byId: 1) ?? "nil")
print("id=99:", findUserName(byId: 99) ?? "nil")

// MARK: - 6.20 Сравнение опционала с обычным значением

print("--- 6.20 Сравнение ---")
let xx: Int? = 25
print("x == 25:", xx == 25)
print("x != nil:", xx != nil)
let yy: Int? = nil
print("y == nil:", yy == nil)
print("x == y:", xx == yy)

// MARK: - Большое упражнение 6.8: cost тремя способами

print("--- 6.8 cost ---")
let menu: [String: Int] = [
    "Латте": 1200,
    "Капучино": 1100,
    "Эспрессо": 600,
    "Раф": 1400,
    "Чизкейк": 2500
]

func cost1(items: [String]) -> Int {
    var total = 0
    for item in items {
        if let price = menu[item] {
            total += price
        }
    }
    return total
}

func cost2(items: [String]) -> Int {
    var total = 0
    for item in items {
        total += menu[item] ?? 0
    }
    return total
}

func cost3(items: [String]) -> Int {
    return items.compactMap { menu[$0] }.reduce(0, +)
}

let order1 = ["Латте", "Капучино"]
let order2 = ["Латте", "Тирамису", "Раф"]
let order3: [String] = []

for order in [order1, order2, order3] {
    let c1 = cost1(items: order)
    let c2 = cost2(items: order)
    let c3 = cost3(items: order)
    print("\(order): \(c1) ₸ / \(c2) ₸ / \(c3) ₸ (все три равны)")
}
