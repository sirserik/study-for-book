import Foundation

// Глава 14A: Storyboard глубже — сегвэи и references.
// В command-line script UIKit недоступен, поэтому моделируем
// сегвэи и flow между VC через mock-классы.
// Реальный код будет в Storyboard + UIKit-классах.

// MARK: - 14A.2 Mock сегвэя и VC

class MockSegue {
    let identifier: String?
    let source: MockViewController
    let destination: MockViewController

    init(identifier: String?, source: MockViewController, destination: MockViewController) {
        self.identifier = identifier
        self.source = source
        self.destination = destination
    }
}

class MockViewController {
    var name: String
    var children: [MockSegue] = []  // segue из этого VC
    weak var presenter: MockViewController?

    init(name: String) {
        self.name = name
    }

    // Эмулирует prepare(for:sender:) — переопределяется в подклассах
    func prepare(for segue: MockSegue, sender: Any?) {
        // override
    }

    // Эмулирует performSegue
    func performSegue(withIdentifier id: String, sender: Any?) {
        guard let segue = children.first(where: { $0.identifier == id }) else {
            print("  [\(name)] performSegue: не найден сегвэй \(id)")
            return
        }
        print("  [\(name)] выполняем segue '\(id)' → \(segue.destination.name)")
        prepare(for: segue, sender: sender)
        segue.destination.presenter = self
        print("  [\(segue.destination.name)] показан")
    }

    // Эмулирует dismiss
    func dismiss() {
        guard let p = presenter else {
            print("  [\(name)] нечего dismiss")
            return
        }
        print("  [\(name)] dismiss → возврат к \(p.name)")
        presenter = nil
    }
}

// MARK: - 14A.3 prepare(for:sender:) — передача данных

struct Product {
    let id: Int
    let title: String
    let price: Int  // в тенге
}

class HomeVC: MockViewController {
    var products: [Product] = []
    var selectedProduct: Product?

    init() {
        super.init(name: "HomeVC")
        // соединяем сегвэем с DetailVC
        let detail = ProductDetailVC()
        children.append(MockSegue(identifier: "showDetail", source: self, destination: detail))
    }

    func selectProduct(at index: Int) {
        selectedProduct = products[index]
        performSegue(withIdentifier: "showDetail", sender: self)
    }

    override func prepare(for segue: MockSegue, sender: Any?) {
        if segue.identifier == "showDetail",
           let dest = segue.destination as? ProductDetailVC {
            dest.product = selectedProduct
            print("    prepare: передали product=\(dest.product?.title ?? "nil") в ProductDetailVC")
        }
    }
}

class ProductDetailVC: MockViewController {
    var product: Product?

    init() {
        super.init(name: "ProductDetailVC")
    }
}

print("--- 14A.3 prepare(for:sender:) ---")
let home = HomeVC()
home.products = [
    Product(id: 1, title: "Латте", price: 1200),
    Product(id: 2, title: "Раф", price: 1400),
    Product(id: 3, title: "Капучино", price: 1100)
]
home.selectProduct(at: 1)

// MARK: - 14A.5 Unwind segue

class FilterVC: MockViewController {
    var selectedFilters: [String] = []

    init() {
        super.init(name: "FilterVC")
    }

    func tapApply() {
        print("  [FilterVC] tap Apply, фильтры: \(selectedFilters)")
        // эмулируем unwind: вызов метода у presenter
        if let home = presenter as? HomeVCWithFilter {
            home.unwindFromFilter(source: self)
        }
        dismiss()
    }
}

class HomeVCWithFilter: MockViewController {
    var activeFilters: [String] = []

    init() {
        super.init(name: "HomeVCWithFilter")
    }

    func openFilter() {
        let filterVC = FilterVC()
        filterVC.presenter = self
        print("  [HomeVCWithFilter] показываем FilterVC")
        // имитация выбора и tap apply
        filterVC.selectedFilters = ["цена<2000", "категория:напитки"]
        filterVC.tapApply()
    }

    // Метод-приёмник unwind segue
    func unwindFromFilter(source: FilterVC) {
        activeFilters = source.selectedFilters
        print("  [HomeVCWithFilter] unwind: получили фильтры \(activeFilters)")
    }
}

print("\n--- 14A.5 Unwind segue ---")
let homeWithFilter = HomeVCWithFilter()
homeWithFilter.openFilter()
print("Активные фильтры в HomeVCWithFilter: \(homeWithFilter.activeFilters)")

// MARK: - 14A.4 Storyboard ID (instantiateViewController)

class MockStoryboard {
    let name: String
    private var registry: [String: () -> MockViewController] = [:]
    private var initialFactory: (() -> MockViewController)?

    init(name: String) {
        self.name = name
    }

    func register(id: String, factory: @escaping () -> MockViewController) {
        registry[id] = factory
    }

    func setInitial(factory: @escaping () -> MockViewController) {
        initialFactory = factory
    }

    func instantiateViewController(withIdentifier id: String) -> MockViewController? {
        return registry[id]?()
    }

    func instantiateInitialViewController() -> MockViewController? {
        return initialFactory?()
    }
}

print("\n--- 14A.4 Storyboard ID ---")
let mainStoryboard = MockStoryboard(name: "Main")
mainStoryboard.register(id: "HomeVC") { HomeVC() }
mainStoryboard.register(id: "ProductDetailVC") { ProductDetailVC() }
mainStoryboard.setInitial { HomeVC() }

if let vc = mainStoryboard.instantiateViewController(withIdentifier: "HomeVC") {
    print("Создали через storyboard ID: \(vc.name)")
}
if let initial = mainStoryboard.instantiateInitialViewController() {
    print("Initial VC: \(initial.name)")
}

// MARK: - 14A.7 Storyboard References — несколько Storyboard

print("\n--- 14A.7 Storyboard References ---")

let authStoryboard = MockStoryboard(name: "Auth")
authStoryboard.setInitial { MockViewController(name: "LoginVC") }
authStoryboard.register(id: "RegisterVC") { MockViewController(name: "RegisterVC") }

let catalogStoryboard = MockStoryboard(name: "Catalog")
catalogStoryboard.setInitial { HomeVC() }

let cartStoryboard = MockStoryboard(name: "Cart")
cartStoryboard.setInitial { MockViewController(name: "CartVC") }

let storyboards = [authStoryboard, catalogStoryboard, cartStoryboard]
for sb in storyboards {
    print("Storyboard \(sb.name).storyboard → initial: \(sb.instantiateInitialViewController()?.name ?? "nil")")
}

// MARK: - 14A.8 Container View — child VC

class ParentVC: MockViewController {
    var childVCs: [MockViewController] = []

    init() {
        super.init(name: "ParentVC")
    }

    // Эмулирует addChild + view.addSubview + didMove(toParent:)
    func addChild(_ child: MockViewController) {
        childVCs.append(child)
        print("  [Parent] addChild(\(child.name))")
        print("  [Parent] view.addSubview(\(child.name).view)")
        print("  [\(child.name)] didMove(toParent: ParentVC)")
    }
}

print("\n--- 14A.8 Container View ---")
let parent = ParentVC()
let child1 = MockViewController(name: "ProductsListVC")
let child2 = MockViewController(name: "FiltersBarVC")
parent.addChild(child1)
parent.addChild(child2)
print("ParentVC содержит \(parent.childVCs.count) child VC")

// MARK: - 14A.9 Size Classes

enum SizeClass {
    case compact
    case regular
}

struct TraitCollection {
    let horizontalSizeClass: SizeClass
    let verticalSizeClass: SizeClass
}

func describeDevice(_ trait: TraitCollection) -> String {
    switch (trait.horizontalSizeClass, trait.verticalSizeClass) {
    case (.compact, .regular):
        return "iPhone portrait"
    case (.compact, .compact):
        return "iPhone landscape"
    case (.regular, .regular):
        return "iPad"
    case (.regular, .compact):
        return "iPad split-view minor"
    }
}

print("\n--- 14A.9 Size Classes ---")
let traits = [
    TraitCollection(horizontalSizeClass: .compact, verticalSizeClass: .regular),
    TraitCollection(horizontalSizeClass: .compact, verticalSizeClass: .compact),
    TraitCollection(horizontalSizeClass: .regular, verticalSizeClass: .regular)
]
for t in traits {
    print("  h=\(t.horizontalSizeClass), v=\(t.verticalSizeClass) → \(describeDevice(t))")
}

// MARK: - 14A.10 IBInspectable demo

class RoundedView {
    var cornerRadius: Double = 0 {
        didSet {
            print("  [RoundedView] layer.cornerRadius = \(cornerRadius)")
            print("  [RoundedView] clipsToBounds = true")
        }
    }
    var borderWidth: Double = 0 {
        didSet {
            print("  [RoundedView] layer.borderWidth = \(borderWidth)")
        }
    }
    var borderColor: String? {
        didSet {
            print("  [RoundedView] layer.borderColor = \(borderColor ?? "nil")")
        }
    }
}

print("\n--- 14A.10 @IBInspectable ---")
let rounded = RoundedView()
print("Имитируем выставление в Storyboard Attributes Inspector:")
rounded.cornerRadius = 12
rounded.borderWidth = 1
rounded.borderColor = "lightGray"

// MARK: - Большое упражнение 14A.1: HomeVC + DetailVC

print("\n--- Упражнение 14A.1: полный flow ---")
let exerciseHome = HomeVC()
exerciseHome.products = [
    Product(id: 10, title: "Шу", price: 800),
    Product(id: 11, title: "Тарт", price: 1500),
    Product(id: 12, title: "Эклер", price: 700)
]

print("Список товаров в HomeVC:")
for (i, p) in exerciseHome.products.enumerated() {
    print("  [\(i)] \(p.title) — \(p.price) ₸")
}

print("\nПользователь тапнул на 'Тарт':")
exerciseHome.selectProduct(at: 1)

// MARK: - Упражнение 14A.3: unwind segue с фильтрами

print("\n--- Упражнение 14A.3: unwind segue ---")
let exerciseHomeWithFilter = HomeVCWithFilter()
print("Активные фильтры в начале: \(exerciseHomeWithFilter.activeFilters)")
exerciseHomeWithFilter.openFilter()
print("Активные фильтры после unwind: \(exerciseHomeWithFilter.activeFilters)")

print("\n--- Done ---")
