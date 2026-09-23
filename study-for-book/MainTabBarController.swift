import UIKit

final class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let productsNav = UINavigationController(rootViewController: ProductsViewController())
        productsNav.tabBarItem = UITabBarItem(
            title: "Товары",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let cartNav = UINavigationController(rootViewController: CartViewController())
        cartNav.tabBarItem = UITabBarItem(
            title: "Корзина",
            image: UIImage(systemName: "cart"),
            selectedImage: UIImage(systemName: "cart.fill")
        )

        viewControllers = [productsNav, cartNav]

        CartStorage.shared.addObserver { [weak self] _ in
            self?.updateCartBadge()
        }
        updateCartBadge()


    }

    private func updateCartBadge() {
        let count = CartStorage.shared.totalCount
        viewControllers?[1].tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
    }
}
