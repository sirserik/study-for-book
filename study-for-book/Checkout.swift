import UIKit

struct CheckoutData {
    var address = ""
    var city = ""
    var zip = ""
    var cardNumber = ""
    var cardCVV = ""
    var cardHolder = ""
}

@MainActor
final class CheckoutCoordinator {
    let navigationController: UINavigationController
    var data = CheckoutData()
    let cartItems: [CartItem]

    var onComplete: (() -> Void)?

    /// Номер оформленного заказа — его покажем пользователю.
    private(set) var placedOrder: Order?

    init(navigationController: UINavigationController, cartItems: [CartItem]) {
        self.navigationController = navigationController
        self.cartItems = cartItems
    }

    var total: Double {
        cartItems.reduce(0) { $0 + $1.product.price * Double($1.quantity) }
    }

    func start() {
        navigationController.pushViewController(CheckoutAddressViewController(coordinator: self), animated: true)
    }

    func goToPayment() {
        navigationController.pushViewController(CheckoutPaymentViewController(coordinator: self), animated: true)
    }

    func goToConfirmation() {
        navigationController.pushViewController(CheckoutConfirmationViewController(coordinator: self), animated: true)
    }

    func placeOrder() async throws {
        let order = try await APIClient.shared.placeOrder(items: cartItems)
        placedOrder = order
        CartStorage.shared.clear()   // заказ ушёл — корзина больше не нужна
    }
}

final class CheckoutProgressView: UIView {
    init(step: Int, total: Int) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        let stack = UIStackView()
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false

        for i in 1...total {
            let dot = UIView()
            dot.backgroundColor = i <= step ? .systemBlue : .systemGray4
            dot.layer.cornerRadius = 3
            dot.heightAnchor.constraint(equalToConstant: 6).isActive = true
            stack.addArrangedSubview(dot)
        }

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }
}

final class CheckoutAddressViewController: UIViewController {

    private let coordinator: CheckoutCoordinator
    private let progress = CheckoutProgressView(step: 1, total: 3)
    private let addressField = UITextField.form(placeholder: "Улица, дом, квартира")
    private let cityField = UITextField.form(placeholder: "Город")
    private let zipField = UITextField.form(placeholder: "Индекс")
    private let nextButton = UIButton.primary(title: "Далее")

    init(coordinator: CheckoutCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Доставка"
        setupLayout()

        addressField.text = coordinator.data.address
        cityField.text = coordinator.data.city
        zipField.text = coordinator.data.zip
        validate()
    }

    private func setupLayout() {
        cityField.text = "Алматы"
        zipField.keyboardType = .numberPad

        for f in [addressField, cityField, zipField] {
            f.addTarget(self, action: #selector(fieldChanged), for: .editingChanged)
        }

        nextButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [progress, addressField, cityField, zipField, nextButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(24, after: progress)
        stack.setCustomSpacing(32, after: zipField)

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    @objc private func fieldChanged() { validate() }

    private func validate() {
        let ok = !(addressField.text ?? "").isEmpty && !(cityField.text ?? "").isEmpty
        nextButton.isEnabled = ok
        nextButton.alpha = ok ? 1 : 0.5
    }

    @objc func nextTapped() {
        coordinator.data.address = addressField.text ?? ""
        coordinator.data.city = cityField.text ?? ""
        coordinator.data.zip = zipField.text ?? ""
        coordinator.goToPayment()
    }
}

final class CheckoutPaymentViewController: UIViewController {

    private let coordinator: CheckoutCoordinator
    private let progress = CheckoutProgressView(step: 2, total: 3)
    private let cardField = UITextField.form(placeholder: "Номер карты")
    private let cvvField = UITextField.form(placeholder: "CVV")
    private let holderField = UITextField.form(placeholder: "Имя на карте (как на карте)")
    private let nextButton = UIButton.primary(title: "Далее")

    init(coordinator: CheckoutCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Оплата"
        setupLayout()

        cardField.text = coordinator.data.cardNumber
        cvvField.text = coordinator.data.cardCVV
        holderField.text = coordinator.data.cardHolder
        validate()
    }

    private func setupLayout() {
        cardField.keyboardType = .numberPad
        cardField.textContentType = .creditCardNumber

        cvvField.keyboardType = .numberPad
        cvvField.isSecureTextEntry = true

        holderField.autocapitalizationType = .allCharacters

        for f in [cardField, cvvField, holderField] {
            f.addTarget(self, action: #selector(fieldChanged), for: .editingChanged)
        }

        nextButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)

        let cardRow = UIStackView(arrangedSubviews: [cardField, cvvField])
        cardRow.axis = .horizontal
        cardRow.spacing = 12
        cvvField.widthAnchor.constraint(equalToConstant: 80).isActive = true

        let stack = UIStackView(arrangedSubviews: [progress, cardRow, holderField, nextButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(24, after: progress)
        stack.setCustomSpacing(32, after: holderField)

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    @objc private func fieldChanged() { validate() }

    private func validate() {
        let digits = (cardField.text ?? "").filter(\.isNumber)
        let cvv = (cvvField.text ?? "").filter(\.isNumber)
        let ok = digits.count >= 16 && (3...4).contains(cvv.count) && !(holderField.text ?? "").isEmpty
        nextButton.isEnabled = ok
        nextButton.alpha = ok ? 1 : 0.5
    }

    @objc func nextTapped() {
        coordinator.data.cardNumber = cardField.text ?? ""
        coordinator.data.cardCVV = cvvField.text ?? ""
        coordinator.data.cardHolder = holderField.text ?? ""
        coordinator.goToConfirmation()
    }
}

final class CheckoutConfirmationViewController: UIViewController {

    private let coordinator: CheckoutCoordinator
    private let progress = CheckoutProgressView(step: 3, total: 3)
    private let summaryLabel = UILabel()
    private let totalLabel = UILabel()
    private let placeOrderButton = UIButton.primary(title: "Подтвердить заказ")
    private let spinner = UIActivityIndicatorView(style: .medium)

    init(coordinator: CheckoutCoordinator) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Подтверждение"
        setupLayout()
        renderSummary()
    }

    private func setupLayout() {
        summaryLabel.font = .systemFont(ofSize: 15)
        summaryLabel.numberOfLines = 0

        totalLabel.font = .systemFont(ofSize: 22, weight: .bold)
        totalLabel.textColor = .systemBlue

        spinner.hidesWhenStopped = true

        placeOrderButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        placeOrderButton.addTarget(self, action: #selector(placeOrderTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [progress, summaryLabel, totalLabel, placeOrderButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(24, after: progress)

        view.addSubview(stack)
        view.addSubview(spinner)
        stack.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            spinner.centerXAnchor.constraint(equalTo: placeOrderButton.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: placeOrderButton.centerYAnchor),
        ])
    }

    private func renderSummary() {
        let d = coordinator.data
        let items = coordinator.cartItems
            .map { "• \($0.product.title) × \($0.quantity)" }
            .joined(separator: "\n")
        summaryLabel.text = """
        Доставка: \(d.city), \(d.address)
        Карта: •••• \(d.cardNumber.suffix(4))

        \(items)
        """
        totalLabel.text = "Итого: " + Money.text(coordinator.total)
    }

    @objc func placeOrderTapped() {
        placeOrderButton.isEnabled = false
        placeOrderButton.configuration?.title = ""
        spinner.startAnimating()

        Task {
            do {
                try await coordinator.placeOrder()
                showSuccess()
            } catch {
                spinner.stopAnimating()
                placeOrderButton.isEnabled = true
                placeOrderButton.configuration?.title = "Подтвердить заказ"
                showError()
            }
        }
    }

    private func showSuccess() {
        let number = coordinator.placedOrder.map { "№\($0.id)" } ?? ""
        let alert = UIAlertController(
            title: "Заказ \(number) оформлен 🎉",
            message: "Спасибо! Мы пришлём подтверждение на email.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default) { [weak self] _ in
            self?.coordinator.onComplete?()
        })
        present(alert, animated: true)
    }

    private func showError() {
        let alert = UIAlertController(
            title: "Не удалось оформить",
            message: "Попробуйте ещё раз. Если проблема не уходит — напишите в поддержку.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}
