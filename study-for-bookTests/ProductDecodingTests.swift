import XCTest
@testable import study_for_book

@MainActor
final class ProductDecodingTests: XCTestCase {

    func test_товарБезКартинкиИОписания_разбирается() throws {
        // Ровно то, что отдаёт наш сервер: thumbnail может быть null.
        let json = Data("""
        [{"id":1,"title":"iPhone 15","description":null,"price":999.99,"thumbnail":null,
          "createdAt":"2026-09-23T09:38:50.892Z"}]
        """.utf8)

        let products = try JSONDecoder().decode([Product].self, from: json)

        XCTAssertEqual(products.count, 1)
        XCTAssertNil(products[0].thumbnail)
        XCTAssertEqual(products[0].price, 999.99)
    }

    func test_датаСМиллисекундами_разбирается() throws {
        // Prisma всегда шлёт миллисекунды, и готовая стратегия .iso8601 на них падает.
        let json = Data("""
        {"id":2,"items":[{"productId":1,"quantity":2}],"total":1999.98,"status":"pending",
         "createdAt":"2026-09-23T09:46:54.132Z"}
        """.utf8)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let text = try decoder.singleValueContainer().decode(String.self)
            if let date = try? Date(text, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true)) {
                return date
            }
            return try Date(text, strategy: .iso8601)
        }

        let order = try decoder.decode(Order.self, from: json)
        XCTAssertEqual(order.id, 2)
        XCTAssertEqual(order.items.first?.quantity, 2)
    }
}
