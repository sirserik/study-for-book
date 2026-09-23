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
            let products = try await fetchProducts(limit: 20)
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

    // Из главы 19 — сетевой код живёт отдельно от интерфейса.
    // В главе 27 переедет в APIClient.
    private func fetchProducts(limit: Int) async throws -> [Product] {
        let url = URL(string: "https://dummyjson.com/products?limit=\(limit)")!
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(ProductsResponse.self, from: data).products
    }
}
