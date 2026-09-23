import UIKit

final class ProfileViewController: UIViewController {

    enum Section: Int, CaseIterable {
        case header, account, orders, other

        var title: String? {
            switch self {
            case .header:  return nil
            case .account: return "Аккаунт"
            case .orders:  return "Заказы"
            case .other:   return "Прочее"
            }
        }
    }

    enum AccountRow: Int, CaseIterable { case name, email, password }
    enum OrdersRow: Int, CaseIterable { case history }
    enum OtherRow: Int, CaseIterable { case about, terms }

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Профиль"

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "value1")
        tableView.register(ProfileHeaderCell.self, forCellReuseIdentifier: ProfileHeaderCell.reuseID)
        tableView.dataSource = self
        tableView.delegate = self

        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshProfile), for: .valueChanged)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadUserRows()
    }

    @objc private func refreshProfile() {
        Task {
            defer { refreshControl.endRefreshing() }
            do {
                let me: User = try await APIClient.shared.request("/users/me")
                AuthService.shared.update(name: me.name, email: me.email)
                reloadUserRows()
            } catch {
                // молча оставляем старые данные
            }
        }
    }

    /// Перерисовывает только те строки, где показан пользователь.
    private func reloadUserRows() {
        guard tableView.numberOfSections > Section.account.rawValue else { return }
        tableView.reconfigureRows(at: [
            IndexPath(row: 0, section: Section.header.rawValue),
            IndexPath(row: AccountRow.name.rawValue, section: Section.account.rawValue),
            IndexPath(row: AccountRow.email.rawValue, section: Section.account.rawValue),
        ])
    }
}

extension ProfileViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section(rawValue: section)?.title
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Section(rawValue: section) {
        case .header:  return 1
        case .account: return AccountRow.allCases.count
        case .orders:  return OrdersRow.allCases.count
        case .other:   return OtherRow.allCases.count
        case .none:    return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Section(rawValue: indexPath.section) {
        case .header:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ProfileHeaderCell.reuseID, for: indexPath
            ) as! ProfileHeaderCell
            cell.configure(with: AuthService.shared.currentUser)
            return cell

        case .account:
            let cell = tableView.dequeueReusableCell(withIdentifier: "value1", for: indexPath)
            var content = cell.defaultContentConfiguration()
            switch AccountRow(rawValue: indexPath.row) {
            case .name:
                content.text = "Имя"
                content.secondaryText = AuthService.shared.currentUser?.name
            case .email:
                content.text = "Email"
                content.secondaryText = AuthService.shared.currentUser?.email
            case .password:
                content.text = "Пароль"
                content.secondaryText = "Сменить"
            case .none: break
            }
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            return cell

        case .orders:
            let cell = tableView.dequeueReusableCell(withIdentifier: "value1", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = "История заказов"
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            return cell

        case .other:
            let cell = tableView.dequeueReusableCell(withIdentifier: "value1", for: indexPath)
            var content = cell.defaultContentConfiguration()
            switch OtherRow(rawValue: indexPath.row) {
            case .about: content.text = "О приложении"
            case .terms: content.text = "Условия использования"
            case .none: break
            }
            cell.contentConfiguration = content
            cell.accessoryType = .disclosureIndicator
            return cell

        case .none:
            return UITableViewCell()
        }
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if Section(rawValue: indexPath.section) == .account,
           AccountRow(rawValue: indexPath.row) == .name {
            navigationController?.pushViewController(EditNameViewController(), animated: true)
        }
    }
}

final class ProfileHeaderCell: UITableViewCell {
    static let reuseID = "ProfileHeaderCell"

    private let avatarView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with user: LoginResponse?) {
        nameLabel.text = user?.name ?? "Гость"
        emailLabel.text = user?.email ?? "Войдите в аккаунт"
    }

    private func setupLayout() {
        selectionStyle = .none

        avatarView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarView.tintColor = .systemGray3
        avatarView.contentMode = .scaleAspectFit

        nameLabel.font = .systemFont(ofSize: 20, weight: .semibold)
        emailLabel.font = .systemFont(ofSize: 14)
        emailLabel.textColor = .secondaryLabel

        [avatarView, nameLabel, emailLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            avatarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            avatarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            avatarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            avatarView.widthAnchor.constraint(equalToConstant: 60),
            avatarView.heightAnchor.constraint(equalToConstant: 60),

            nameLabel.leadingAnchor.constraint(equalTo: avatarView.trailingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: avatarView.topAnchor, constant: 6),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            emailLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
        ])
    }
}

final class EditNameViewController: UIViewController {

    private let nameField = UITextField.form(placeholder: "Имя")
    private let saveButton = UIButton.primary(title: "Сохранить")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        title = "Имя"
        setupLayout()
        nameField.text = AuthService.shared.currentUser?.name
    }

    private func setupLayout() {
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [nameField, saveButton])
        stack.axis = .vertical
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }

    @objc private func saveTapped() {
        guard let name = nameField.text, !name.isEmpty else { return }
        saveButton.isEnabled = false
        Task {
            do {
                struct Body: Encodable { let name: String }
                let updated: User = try await APIClient.shared.request(
                    "/users/me", method: .PATCH, body: Body(name: name)
                )
                AuthService.shared.update(name: updated.name, email: updated.email)
                navigationController?.popViewController(animated: true)
            } catch {
                saveButton.isEnabled = true
                let alert = UIAlertController(title: "Не сохранилось",
                                              message: "Попробуй ещё раз",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
            }
        }
    }
}
