import UIKit

final class ProductsViewController: UIViewController {

    private let tableView = UITableView()
    private let viewModel = ProductsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Товары"
        setupTable()

        viewModel.onUpdate = { [weak self] in
            self?.render()
        }
        Task { await viewModel.load() }
    }

    /// View показывает состояние — и только его.
    private func render() {
        tableView.reloadData()

        if case .error(let message) = viewModel.state {
            let alert = UIAlertController(title: "Ошибка",
                                          message: message,
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }

    private func setupTable() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        tableView.register(ProductCell.self, forCellReuseIdentifier: ProductCell.reuseID)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 110
        tableView.dataSource = self
    }
}

extension ProductsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfRows()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ProductCell.reuseID, for: indexPath
        ) as! ProductCell
        let p = viewModel.product(at: indexPath.row)
        cell.configure(p)
        return cell
    }
}

