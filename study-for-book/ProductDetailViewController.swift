import UIKit

final class ProductDetailViewController: UIViewController {

    private let product: Product

    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let productImageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let addToCartButton = UIButton.primary(title: "В корзину 🛒")

    init(product: Product) {
        self.product = product
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = product.title
        navigationItem.largeTitleDisplayMode = .never
        setupLayout()
        configure()
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),

            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
        ])

        contentView.addSubview(productImageView)
        productImageView.translatesAutoresizingMaskIntoConstraints = false
        productImageView.contentMode = .scaleAspectFit
        productImageView.backgroundColor = .systemGray6

        NSLayoutConstraint.activate([
            productImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: 16),
            productImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            productImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            productImageView.heightAnchor.constraint(
                equalTo: productImageView.widthAnchor),
        ])

        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: productImageView.bottomAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
        ])

        contentView.addSubview(priceLabel)
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.font = .systemFont(ofSize: 28, weight: .heavy)
        priceLabel.textColor = .systemBlue

        NSLayoutConstraint.activate([
            priceLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: 8),
            priceLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
        ])

        contentView.addSubview(descriptionLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.textColor = .label
        descriptionLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(
                equalTo: priceLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
        ])

        contentView.addSubview(addToCartButton)
        addToCartButton.translatesAutoresizingMaskIntoConstraints = false
        addToCartButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            addToCartButton.topAnchor.constraint(
                equalTo: descriptionLabel.bottomAnchor, constant: 32),
            addToCartButton.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            addToCartButton.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            addToCartButton.heightAnchor.constraint(equalToConstant: 52),
            addToCartButton.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -32),
        ])
    }

    private func configure() {
        productImageView.setImage(from: product.thumbnail,
                                  placeholder: UIImage(systemName: "photo"))
        titleLabel.text = product.title
        priceLabel.text = Money.text(product.price)
        descriptionLabel.text = product.description
    }

    @objc private func addToCartTapped() {
        CartStorage.shared.add(product)

        let alert = UIAlertController(
            title: "Добавлено",
            message: "\(product.title) в корзине",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
