import XCTest
@testable import study_for_book

@MainActor
final class CartStorageTests: XCTestCase {

    private var storage: CartStorage!

    override func setUp() async throws {
        try await super.setUp()
        storage = CartStorage(store: InMemoryStore(), key: "cart.test")
    }

    private func makeProduct(id: Int = 1, price: Double = 100) -> Product {
        Product(id: id, title: "Товар \(id)", description: nil, price: price, thumbnail: nil)
    }

    func test_пустаяКорзина_суммаНоль() {
        XCTAssertEqual(storage.totalPrice, 0)
        XCTAssertEqual(storage.totalCount, 0)
        XCTAssertTrue(storage.items.isEmpty)
    }

    func test_добавлениеОдногоТовараДважды_увеличиваетКоличество() {
        let product = makeProduct(price: 9.99)
        storage.add(product)
        storage.add(product)

        XCTAssertEqual(storage.items.count, 1, "две позиции одного товара должны схлопнуться в одну")
        XCTAssertEqual(storage.totalCount, 2)
        XCTAssertEqual(storage.totalPrice, 19.98, accuracy: 0.001)
    }

    func test_суммаПоНесколькимТоварам() {
        storage.add(makeProduct(id: 1, price: 999.99))
        storage.add(makeProduct(id: 1, price: 999.99))
        storage.add(makeProduct(id: 2, price: 249))

        XCTAssertEqual(storage.totalPrice, 2248.98, accuracy: 0.001)
    }

    func test_уменьшениеДоНуля_удаляетТовар() {
        let product = makeProduct(id: 7)
        storage.add(product)
        storage.updateQuantity(productId: 7, by: -1)

        XCTAssertTrue(storage.items.isEmpty, "при количестве 0 товар уходит из корзины")
    }

    func test_удалениеПоId() {
        storage.add(makeProduct(id: 1))
        storage.add(makeProduct(id: 2))
        storage.remove(productId: 1)

        XCTAssertEqual(storage.items.map(\.product.id), [2])
    }

    /// Корзина, записанная одним экземпляром, читается другим — как после перезапуска.
    private var firstStorage: CartStorage!
    private var secondStorage: CartStorage!

    func test_корзинаПереживаетПересозданиеХранилища() {
        let store = InMemoryStore()
        firstStorage = CartStorage(store: store, key: "cart.test")
        firstStorage.add(makeProduct(id: 3, price: 50))

        secondStorage = CartStorage(store: store, key: "cart.test")
        secondStorage.load()

        XCTAssertEqual(secondStorage.totalCount, 1)
        XCTAssertEqual(secondStorage.totalPrice, 50)
    }

    func test_очисткаКорзины() {
        storage.add(makeProduct())
        storage.clear()

        XCTAssertTrue(storage.items.isEmpty)
        XCTAssertEqual(storage.totalPrice, 0)
    }
}
