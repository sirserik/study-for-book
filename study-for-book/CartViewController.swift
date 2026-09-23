import UIKit

final class CartViewController: UIViewController {

    private let tableView = UITableView()
    private let totalLabel = UILabel()
    private let checkoutButton = UIButton.primary(title: "Оформить заказ")
    private let emptyLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Корзина"
        setupLayout()

        CartStorage.shared.addObserver { [weak self] change in
            self?.apply(change)
        }
        apply(.reloaded)
    }

    private func apply(_ change: CartChange) {
        let items = CartStorage.shared.items

        switch change {
        case .quantityChanged(let index):
            // меняем ТОЛЬКО цифру в одной ячейке
            let path = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: path) as? CartItemCell {
                cell.setQuantity(items[index].quantity)
            }
        case .added(let index):
            tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        case .removed(let index):
            tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        case .reloaded:
            tableView.reloadData()
        }

        refreshTotals()
    }

    /// Сумма, доступность кнопки, заглушка и бейдж — это дёшево, считаем всегда.
    private func refreshTotals() {
        totalLabel.text = "Итого: " + Money.text(CartStorage.shared.totalPrice)
        checkoutButton.isEnabled = !CartStorage.shared.items.isEmpty
        let isEmpty = CartStorage.shared.items.isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        updateBadge()
    }

    private func updateBadge() {
        let count = CartStorage.shared.totalCount
        navigationController?.tabBarItem.badgeValue = count > 0 ? "\(count)" : nil
    }

    private func setupLayout() {
        let bottomBar = UIView()
        bottomBar.backgroundColor = .secondarySystemBackground
        [tableView, bottomBar, totalLabel, checkoutButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        view.addSubview(tableView)
        view.addSubview(bottomBar)
        bottomBar.addSubview(totalLabel)
        bottomBar.addSubview(checkoutButton)

        totalLabel.font = .systemFont(ofSize: 18, weight: .bold)

        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)

        emptyLabel.text = "Корзина пуста"
        emptyLabel.font = .systemFont(ofSize: 17)
        emptyLabel.textColor = .secondaryLabel
        emptyLabel.textAlignment = .center
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomBar.heightAnchor.constraint(equalToConstant: 110),

            totalLabel.topAnchor.constraint(equalTo: bottomBar.topAnchor, constant: 12),
            totalLabel.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),

            checkoutButton.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: 8),
            checkoutButton.leadingAnchor.constraint(equalTo: bottomBar.leadingAnchor, constant: 16),
            checkoutButton.trailingAnchor.constraint(equalTo: bottomBar.trailingAnchor, constant: -16),
            checkoutButton.heightAnchor.constraint(equalToConstant: 50),

            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])

        tableView.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 80
    }

    @objc private func checkoutTapped() {
        guard !CartStorage.shared.items.isEmpty,
              let nav = navigationController else { return }

        guard AuthService.shared.isLoggedIn else {
            showLogin(from: nav)
            return
        }

        startCheckout(in: nav)
    }

    private func startCheckout(in nav: UINavigationController) {
        let coordinator = CheckoutCoordinator(
            navigationController: nav,
            cartItems: CartStorage.shared.items
        )
        coordinator.onComplete = { [weak self] in
            nav.popToRootViewController(animated: true)
            self?.tabBarController?.selectedIndex = 0
        }
        coordinator.start()
    }

    private func showLogin(from nav: UINavigationController) {
        let login = LoginViewController()
        login.onSuccess = { [weak self, weak nav] in
            guard let self, let nav else { return }
            nav.dismiss(animated: true) {
                self.startCheckout(in: nav)
            }
        }
        present(UINavigationController(rootViewController: login), animated: true)
    }
}

extension CartViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        CartStorage.shared.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: CartItemCell.reuseID, for: indexPath
        ) as! CartItemCell
        let item = CartStorage.shared.items[indexPath.row]
        cell.configure(with: item)
        return cell
    }
}

extension CartViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Удалить") { _, _, completion in
            let item = CartStorage.shared.items[indexPath.row]
            CartStorage.shared.remove(productId: item.product.id)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [delete])
    }
}
