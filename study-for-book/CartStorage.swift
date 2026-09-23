import Foundation

struct CartItem: Codable {
    let product: Product
    var quantity: Int
}

/// Что именно поменялось в корзине.
enum CartChange {
    case reloaded                       // загрузили с диска или очистили
    case added(index: Int)              // появился новый товар
    case quantityChanged(index: Int)    // у товара изменилось количество
    case removed(index: Int)            // товар убрали
}

@MainActor
final class CartStorage {
    static let shared = CartStorage()
    private init() {}

    private let key = "cart.items"
    private(set) var items: [CartItem] = []

    private var observers: [(CartChange) -> Void] = []

    func addObserver(_ block: @escaping (CartChange) -> Void) {
        observers.append(block)
    }

    private func notify(_ change: CartChange) {
        for block in observers { block(change) }
    }

    func load() {
        guard let data = UserDefaults.standard.data(forKey: key) else { return }
        guard let saved = try? JSONDecoder().decode([CartItem].self, from: data) else { return }
        items = saved
        save(.reloaded)
    }

    /// Пишет корзину на диск и сообщает подписчикам, что изменилось.
    private func save(_ change: CartChange) {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: key)
        }
        notify(change)
    }

    func add(_ product: Product) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += 1
            save(.quantityChanged(index: index))
        } else {
            items.append(CartItem(product: product, quantity: 1))
            save(.added(index: items.count - 1))
        }
    }

    func remove(productId: Int) {
        guard let index = items.firstIndex(where: { $0.product.id == productId }) else { return }
        items.remove(at: index)
        save(.removed(index: index))
    }

    func updateQuantity(productId: Int, by delta: Int) {
        guard let index = items.firstIndex(where: { $0.product.id == productId }) else { return }
        items[index].quantity += delta
        if items[index].quantity <= 0 {
            items.remove(at: index)
            save(.removed(index: index))
        } else {
            save(.quantityChanged(index: index))
        }
    }

    func clear() {
        items.removeAll()
        save(.reloaded)
    }

    var totalPrice: Double {
        items.reduce(0) { $0 + $1.product.price * Double($1.quantity) }
    }

    var totalCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
}
