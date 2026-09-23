import UIKit

final class LoginViewController: UIViewController {

    private let stack = UIStackView()
    private let emailField = UITextField.form(placeholder: "Email")
    private let passwordField = UITextField.form(placeholder: "Пароль")
    private let loginButton = UIButton.primary(title: "Войти")
    private let goRegisterButton = UIButton(type: .system)
    private let errorLabel = UILabel()

    var onSuccess: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Вход"
        setupLayout()
    }

    private func setupLayout() {
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.textContentType = .username

        passwordField.isSecureTextEntry = true
        passwordField.textContentType = .password

        loginButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        goRegisterButton.setTitle("Создать аккаунт", for: .normal)
        goRegisterButton.addTarget(self, action: #selector(goRegisterTapped), for: .touchUpInside)

        errorLabel.font = .systemFont(ofSize: 13)
        errorLabel.textColor = .systemRed
        errorLabel.numberOfLines = 0
        errorLabel.isHidden = true

        stack.axis = .vertical
        stack.spacing = 16
        [emailField, passwordField, errorLabel, loginButton, goRegisterButton]
            .forEach { stack.addArrangedSubview($0) }

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }

    @objc func loginTapped() {
        guard let email = emailField.text, let password = passwordField.text else { return }
        errorLabel.isHidden = true
        loginButton.isEnabled = false
        loginButton.configuration?.title = "Входим…"

        Task {
            do {
                _ = try await AuthService.shared.login(email: email, password: password)
                onSuccess?()
            } catch AuthError.invalidCredentials {
                showError("Неверный email или пароль")
            } catch {
                showError("Ошибка сети. Попробуйте ещё раз")
            }
        }
    }

    @objc private func goRegisterTapped() {
        let vc = RegistrationViewController()
        vc.onSuccess = { [weak self] in self?.onSuccess?() }
        navigationController?.pushViewController(vc, animated: true)
    }

    private func showError(_ message: String) {
        errorLabel.text = message
        errorLabel.isHidden = false
        loginButton.isEnabled = true
        loginButton.configuration?.title = "Войти"
    }

    // для тестового прогона без тапов
    func fill(email: String, password: String) {
        emailField.text = email
        passwordField.text = password
    }
}
