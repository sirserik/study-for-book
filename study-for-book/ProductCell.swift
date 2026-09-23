import UIKit

final class ProductCell: UITableViewCell {
    static let reuseID = "ProductCell"

    private let productImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let priceLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }

    func configure(_ product: Product) {
        titleLabel.text = product.title
        subtitleLabel.text = product.description
        priceLabel.text = Money.text(product.price)
        productImageView.setImage(from: product.thumbnail,
                                  placeholder: UIImage(systemName: "photo"))
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        productImageView.image = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        priceLabel.text = nil
    }

    private func setupViews() {
        contentView.addSubview(productImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(priceLabel)

        productImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        productImageView.contentMode = .scaleAspectFill
        productImageView.clipsToBounds = true
        productImageView.layer.cornerRadius = 8
        productImageView.backgroundColor = .systemGray6

        titleLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        titleLabel.numberOfLines = 1

        subtitleLabel.font = .systemFont(ofSize: 13)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        priceLabel.font = .systemFont(ofSize: 15, weight: .bold)
        priceLabel.textColor = .systemBlue

        NSLayoutConstraint.activate([
            productImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            productImageView.topAnchor.constraint(
                equalTo: contentView.topAnchor, constant: 12),
            productImageView.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor, constant: -12),
            productImageView.widthAnchor.constraint(equalToConstant: 80),
            productImageView.heightAnchor.constraint(equalToConstant: 80),

            titleLabel.leadingAnchor.constraint(
                equalTo: productImageView.trailingAnchor, constant: 12),
            titleLabel.topAnchor.constraint(
                equalTo: productImageView.topAnchor),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),

            subtitleLabel.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor),
            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.trailingAnchor.constraint(
                equalTo: titleLabel.trailingAnchor),

            priceLabel.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor),
            priceLabel.bottomAnchor.constraint(
                equalTo: productImageView.bottomAnchor),
        ])
    }
}
