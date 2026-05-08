import Foundation

// MARK: - 10A.4 Базовый decoding

struct Product: Codable {
    let title: String
    let price: Int
}

let json1 = """
{"title": "iPhone 15", "price": 79900}
"""

print("--- 10A.4 Базовый ---")
let p1 = try JSONDecoder().decode(Product.self, from: Data(json1.utf8))
print(p1.title, p1.price)

// массив
let json2 = """
[
  {"title": "iPhone", "price": 79900},
  {"title": "iPad",   "price": 65000}
]
"""

let products = try JSONDecoder().decode([Product].self, from: Data(json2.utf8))
print("count:", products.count)
print("first:", products[0].title)

// MARK: - 10A.5 Encoding

print("--- 10A.5 Encoding ---")
let encoder = JSONEncoder()
let p = Product(title: "Латте", price: 1200)
let encoded = try encoder.encode(p)
print(String(decoding: encoded, as: UTF8.self))

// pretty
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let prettyData = try encoder.encode(products)
print(String(decoding: prettyData, as: UTF8.self))

// MARK: - 10A.6 Optional fields

struct ProductOpt: Codable {
    let title: String
    let price: Int
    let discount: Int?
}

let json3 = """
[
  {"title": "iPhone", "price": 79900, "discount": 10},
  {"title": "iPad",   "price": 65000}
]
"""

print("--- 10A.6 Optional ---")
let opts = try JSONDecoder().decode([ProductOpt].self, from: Data(json3.utf8))
print(opts[0].discount ?? -1)
print(opts[1].discount ?? -1)

// MARK: - 10A.7 keyDecodingStrategy

struct User: Codable {
    let firstName: String
    let lastName: String
    let emailAddress: String
}

let json4 = """
{
  "first_name": "Айдос",
  "last_name": "Серикулы",
  "email_address": "aidos@example.kz"
}
"""

print("--- 10A.7 snake_case ---")
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase
let user = try decoder.decode(User.self, from: Data(json4.utf8))
print("\(user.firstName) \(user.lastName) — \(user.emailAddress)")

// MARK: - 10A.8 CodingKeys

struct UserCK: Codable {
    let firstName: String
    let lastName: String
    let url: URL

    enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case url = "profile_url"
    }
}

let json5 = """
{
  "first_name": "Айгерим",
  "last_name": "Серикулы",
  "profile_url": "https://shop.example.kz/users/2"
}
"""

print("--- 10A.8 CodingKeys ---")
let userCK = try JSONDecoder().decode(UserCK.self, from: Data(json5.utf8))
print("\(userCK.firstName) \(userCK.lastName) — \(userCK.url)")

// MARK: - 10A.9 Enum в Codable

enum OrderStatus: String, Codable {
    case pending, confirmed, shipped, delivered, cancelled
}

struct Order: Codable {
    let id: Int
    let status: OrderStatus
    let total: Int
}

let json6 = """
{"id": 1, "status": "shipped", "total": 4500}
"""

print("--- 10A.9 Enum ---")
let order = try JSONDecoder().decode(Order.self, from: Data(json6.utf8))
print("Order \(order.id): \(order.status) — \(order.total) ₸")

// MARK: - 10A.10 URL

struct Profile: Codable {
    let id: Int
    let avatarURL: URL?
}

let json7 = """
{"id": 1, "avatarURL": "https://example.kz/avatars/1.png"}
"""

print("--- 10A.10 URL ---")
let profile = try JSONDecoder().decode(Profile.self, from: Data(json7.utf8))
print(profile.avatarURL?.absoluteString ?? "nil")

// MARK: - 10A.11 Даты ISO8601

struct OrderDated: Codable {
    let title: String
    let createdAt: Date
}

let json8 = """
{"title": "Заказ #1234", "createdAt": "2026-05-07T10:30:00Z"}
"""

let decoderD = JSONDecoder()
decoderD.dateDecodingStrategy = .iso8601

print("--- 10A.11 Даты ISO8601 ---")
let od = try decoderD.decode(OrderDated.self, from: Data(json8.utf8))
print(od.title, od.createdAt)

// миллисекунды
let json9 = """
{"title": "Заказ", "createdAt": "2026-05-07T10:30:00.123Z"}
"""

let formatter = ISO8601DateFormatter()
formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

let decoderMs = JSONDecoder()
decoderMs.dateDecodingStrategy = .custom { d in
    let container = try d.singleValueContainer()
    let s = try container.decode(String.self)
    if let date = formatter.date(from: s) {
        return date
    }
    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Bad date: \(s)")
}

print("--- 10A.11 Даты с миллисекундами ---")
let odMs = try decoderMs.decode(OrderDated.self, from: Data(json9.utf8))
print(odMs.title, odMs.createdAt)

// MARK: - 10A.12 Кастомный init(from:)

struct ProductCustom: Codable {
    let id: Int
    let title: String
    let price: Double
    let isAvailable: Bool

    enum CodingKeys: String, CodingKey {
        case id, title, price, isAvailable
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.title = try container.decode(String.self, forKey: .title)

        // price может прийти как Double или String
        if let p = try? container.decode(Double.self, forKey: .price) {
            self.price = p
        } else if let s = try? container.decode(String.self, forKey: .price),
                  let p = Double(s) {
            self.price = p
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .price, in: container,
                debugDescription: "price must be Double or String")
        }

        // isAvailable необязательное, дефолт true
        self.isAvailable = try container.decodeIfPresent(Bool.self, forKey: .isAvailable) ?? true
    }
}

let json10a = """
{"id": 1, "title": "Латте", "price": 1200.0, "isAvailable": false}
"""
let json10b = """
{"id": 2, "title": "Раф", "price": "1400"}
"""

print("--- 10A.12 Кастомный init ---")
let pc1 = try JSONDecoder().decode(ProductCustom.self, from: Data(json10a.utf8))
print("pc1:", pc1.id, pc1.title, pc1.price, "available:", pc1.isAvailable)
let pc2 = try JSONDecoder().decode(ProductCustom.self, from: Data(json10b.utf8))
print("pc2:", pc2.id, pc2.title, pc2.price, "available:", pc2.isAvailable)

// MARK: - 10A.13 Heterogeneous arrays

enum Message: Decodable {
    case text(content: String)
    case image(url: URL)
    case video(url: URL, duration: Int)

    enum CodingKeys: String, CodingKey {
        case type, content, url, duration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch type {
        case "text":
            let content = try container.decode(String.self, forKey: .content)
            self = .text(content: content)
        case "image":
            let url = try container.decode(URL.self, forKey: .url)
            self = .image(url: url)
        case "video":
            let url = try container.decode(URL.self, forKey: .url)
            let duration = try container.decode(Int.self, forKey: .duration)
            self = .video(url: url, duration: duration)
        default:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "Unknown type: \(type)")
        }
    }
}

let json11 = """
[
  {"type": "text", "content": "Сәлем"},
  {"type": "image", "url": "https://example.kz/photo.png"},
  {"type": "video", "url": "https://example.kz/clip.mp4", "duration": 120}
]
"""

print("--- 10A.13 Heterogeneous ---")
let messages = try JSONDecoder().decode([Message].self, from: Data(json11.utf8))
for message in messages {
    switch message {
    case .text(let content): print("Текст:", content)
    case .image(let url): print("Картинка:", url)
    case .video(let url, let duration): print("Видео:", url, "—", duration, "сек")
    }
}

// MARK: - 10A.14 DecodingError по типам

let badJson = """
{"id": "не число", "title": "X"}
"""

struct BadProduct: Codable {
    let id: Int
    let title: String
}

print("--- 10A.14 DecodingError ---")
do {
    let _ = try JSONDecoder().decode(BadProduct.self, from: Data(badJson.utf8))
} catch DecodingError.typeMismatch(let type, let context) {
    print("Тип не совпал \(type):", context.debugDescription)
} catch {
    print("Другая ошибка:", error)
}

// MARK: - Большое упражнение 10A.4 — полный response

print("--- 10A.4 ShopApp Response ---")

enum OrderStatusFull: String, Codable, Sendable {
    case pending, confirmed, shipped, delivered, cancelled
}

struct UserFull: Codable, Sendable {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let avatarUrl: URL?
}

struct OrderFull: Codable, Sendable {
    let id: String
    let total: Int
    let status: OrderStatusFull
    let completed: Bool
    let createdAt: Date
}

struct Response: Codable, Sendable {
    let user: UserFull
    let orders: [OrderFull]
}

let bigJson = """
{
  "user": {
    "id": 42,
    "first_name": "Айдос",
    "last_name": "Серикулы",
    "email": "aidos@example.kz",
    "avatar_url": "https://shop.example.kz/avatars/42.png"
  },
  "orders": [
    {
      "id": "ORD-001",
      "total": 4500,
      "status": "shipped",
      "completed": true,
      "created_at": "2026-05-07T10:30:00Z"
    },
    {
      "id": "ORD-002",
      "total": 1200,
      "status": "pending",
      "completed": false,
      "created_at": "2026-05-08T09:15:30Z"
    },
    {
      "id": "ORD-003",
      "total": 8900,
      "status": "shipped",
      "completed": true,
      "created_at": "2026-05-06T15:00:00Z"
    }
  ]
}
"""

let bigDecoder = JSONDecoder()
bigDecoder.keyDecodingStrategy = .convertFromSnakeCase
bigDecoder.dateDecodingStrategy = .iso8601

let response = try bigDecoder.decode(Response.self, from: Data(bigJson.utf8))

print("Пользователь: \(response.user.firstName) \(response.user.lastName)")
print("Email: \(response.user.email)")
print("Аватар: \(response.user.avatarUrl?.absoluteString ?? "—")")

let totalSum = response.orders.reduce(0) { $0 + $1.total }
print("Заказов: \(response.orders.count), общая сумма: \(totalSum) ₸")

let shipped = response.orders
    .filter { $0.status == .shipped }
    .sorted(by: { $0.createdAt < $1.createdAt })

print("\nОтправленные (по дате):")
for order in shipped {
    print("  \(order.id) — \(order.total) ₸, \(order.createdAt)")
}
