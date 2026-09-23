import UIKit

final class CartItemCell: UITableViewCell {
    static let reuseID = "CartItemCell"

    private let productImageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let minusButton = UIButton(type: .system)
    private let quantityLabel = UILabel()
    private let plusButton = UIButton(type: .system)

    private var productId: Int = 0

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
        minusButton.addTarget(self, action: #selector(minusTapped), for: .touchUpInside)
        plusButton.addTarget(self, action: #selector(plusTapped), for: .touchUpInside)
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with item: CartItem) {
        productId = item.product.id
        titleLabel.text = item.product.title
        priceLabel.text = Money.text(item.product.price)
        quantityLabel.text = "\(item.quantity)"
        productImageView.setImage(from: item.product.thumbnail)
    }

    /// Точечное обновление — меняем только цифру, не трогая картинку и текст.
    func setQuantity(_ quantity: Int) {
        quantityLabel.text = "\(quantity)"
    }

    @objc private func minusTapped() {
        CartStorage.shared.updateQuantity(productId: productId, by: -1)
    }

    @objc private func plusTapped() {
        CartStorage.shared.updateQuantity(productId: productId, by: +1)
    }

    private func setupLayout() {
        [productImageView, titleLabel, priceLabel,
         minusButton, quantityLabel, plusButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 8
        productImageView.backgroundColor = .systemGray6

        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.numberOfLines = 2

        priceLabel.font = .systemFont(ofSize: 14)
        priceLabel.textColor = .systemBlue

        for btn in [minusButton, plusButton] {
            btn.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
            btn.layer.borderColor = UIColor.systemGray4.cgColor
            btn.layer.borderWidth = 1
            btn.layer.cornerRadius = 14
        }
        minusButton.setTitle("−", for: .normal)
        plusButton.setTitle("+", for: .normal)

        quantityLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        quantityLabel.textAlignment = .center

        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            productImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            productImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            productImageView.widthAnchor.constraint(equalToConstant: 64),
            productImageView.heightAnchor.constraint(equalToConstant: 64),

            titleLabel.leadingAnchor.constraint(equalTo: productImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(equalTo: productImageView.topAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: minusButton.leadingAnchor, constant: -12),

            priceLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            priceLabel.bottomAnchor.constraint(equalTo: productImageView.bottomAnchor),

            plusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            plusButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            plusButton.widthAnchor.constraint(equalToConstant: 28),
            plusButton.heightAnchor.constraint(equalToConstant: 28),

            quantityLabel.trailingAnchor.constraint(equalTo: plusButton.leadingAnchor, constant: -8),
            quantityLabel.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            quantityLabel.widthAnchor.constraint(equalToConstant: 24),

            minusButton.trailingAnchor.constraint(equalTo: quantityLabel.leadingAnchor, constant: -8),
            minusButton.centerYAnchor.constraint(equalTo: plusButton.centerYAnchor),
            minusButton.widthAnchor.constraint(equalToConstant: 28),
            minusButton.heightAnchor.constraint(equalToConstant: 28),
        ])
    }
}
