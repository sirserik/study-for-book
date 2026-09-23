import Foundation

// Глава 19. URLSession — первый сетевой запрос.
//
// Примечание про запуск. Верхний уровень плейграунда в режиме Swift 6 —
// это MainActor, и `await` работает здесь напрямую, без обёртки Task { }.
// Внутри обычной синхронной функции (например, в viewDidLoad) Task
// обязателен — об этом в 19.4.

// MARK: - 19.3 URL

let url = URL(string: "https://dummyjson.com/products?limit=5")!
print(url)

// Опционал не просто так: пустая строка адресом быть не может.
print("пустая строка ->", URL(string: "") as Any)          // nil
// А вот пробел современный Foundation кодирует сам:
print("с пробелом  ->", URL(string: "https://dummyjson.com/pro ducts") as Any)

// MARK: - 19.4 Первый запрос

let (data, response) = try await URLSession.shared.data(from: url)
print("Получили \(data.count) байт")
print("Ответ:", response)

// MARK: - 19.5 Смотрим на байты глазами

if let text = String(data: data, encoding: .utf8) {
    print(text.prefix(200))
}

// MARK: - 19.6 Парсим через Codable

struct Product: Codable {
    let id: Int
    let title: String
    let price: Double
    let description: String
}

struct ProductsResponse: Codable {
    let products: [Product]
    let total: Int
    let skip: Int
    let limit: Int
}

let parsed = try JSONDecoder().decode(ProductsResponse.self, from: data)
print("Всего товаров на сервере: \(parsed.total)")
print("Получено: \(parsed.products.count)")
for p in parsed.products {
    print("- \(p.title) — \(p.price)$")
}

// MARK: - 19.7 Проверяем статус-код

guard let http = response as? HTTPURLResponse,
      (200..<300).contains(http.statusCode) else {
    throw URLError(.badServerResponse)
}
print("Статус:", http.statusCode)

// MARK: - 19.8 POST

struct NewProduct: Codable {
    let title: String
}

var request = URLRequest(url: URL(string: "https://dummyjson.com/products/add")!)
request.httpMethod = "POST"
request.setValue("application/json", forHTTPHeaderField: "Content-Type")
request.httpBody = try JSONEncoder().encode(NewProduct(title: "Мой первый товар"))

let (postData, postResponse) = try await URLSession.shared.data(for: request)
if let http = postResponse as? HTTPURLResponse {
    print("Статус: \(http.statusCode)")
}
print("Ответ:", String(data: postData, encoding: .utf8) ?? "")

// MARK: - 19.9 Заворачиваем в функцию

func fetchProducts(limit: Int) async throws -> [Product] {
    let url = URL(string: "https://dummyjson.com/products?limit=\(limit)")!
    let (data, response) = try await URLSession.shared.data(from: url)

    guard let http = response as? HTTPURLResponse,
          (200..<300).contains(http.statusCode) else {
        throw URLError(.badServerResponse)
    }

    return try JSONDecoder().decode(ProductsResponse.self, from: data).products
}

let three = try await fetchProducts(limit: 3)
for p in three {
    print(p.title)
}
