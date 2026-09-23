import Foundation

struct Order: Codable, Identifiable {
    struct Item: Codable {
        let productId: Int
        let quantity: Int
    }

    let id: Int
    let items: [Item]
    let total: Double
    let status: String
    let createdAt: Date
}
