import Foundation

/// Состояние экрана: одно из четырёх, третьего не дано.
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)
}

@MainActor
final class ProductsViewModel {

    private(set) var state: ViewState<[Product]> = .idle

    /// View подписывается сюда, чтобы узнать об изменениях.
    var onUpdate: (() -> Void)?

    func load() async {
        state = .loading
        onUpdate?()

        do {
            let products = try await APIClient.shared.getProducts()
            state = .loaded(products)
        } catch {
            state = .error("Не удалось загрузить товары")
        }
        onUpdate?()
    }

    /// Готовая строка для UI: собирает её ViewModel, а не ViewController.
    var statusText: String {
        switch state {
        case .idle:               return "Ещё не загружали"
        case .loading:            return "Загружаем…"
        case .loaded(let items):  return "Загружено товаров: \(items.count)"
        case .error(let message): return message
        }
    }

    /// Товары, если они загружены. В остальных состояниях — пусто.
    var products: [Product] {
        if case .loaded(let items) = state { return items }
        return []
    }

    func numberOfRows() -> Int { products.count }

    func product(at index: Int) -> Product { products[index] }

}
