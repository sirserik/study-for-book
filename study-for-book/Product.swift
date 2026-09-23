import Foundation

struct Product: Codable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let thumbnail: String
}

struct ProductsResponse: Codable {
    let products: [Product]
}
