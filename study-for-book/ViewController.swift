import UIKit

class ViewController: UIViewController {

    private let viewModel = ProductsViewModel()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        statusLabel.font = .preferredFont(forTextStyle: .title2)
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0

        view.addSubview(statusLabel)
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        // Связь ViewModel -> View
        viewModel.onUpdate = { [weak self] in
            self?.refresh()
        }
        refresh()

        Task { await viewModel.load() }
    }

    /// View только показывает то, что подготовила ViewModel.
    private func refresh() {
        statusLabel.text = viewModel.statusText
    }
}
