import UIKit

enum FormError: LocalizedError {
    case nameTooShort
    case invalidEmail
    case passwordTooShort

    var errorDescription: String? {
        switch self {
        case .nameTooShort:     return "Имя должно быть минимум 2 символа"
        case .invalidEmail:     return "Неверный email"
        case .passwordTooShort: return "Пароль минимум 8 символов"
        }
    }
}

struct RegistrationForm {
    let name: String
    let email: String
    let password: String

    func validate() -> [FormError] {
        var errors: [FormError] = []
        if name.count < 2 { errors.append(.nameTooShort) }
        if !isValidEmail(email) { errors.append(.invalidEmail) }
        if password.count < 8 { errors.append(.passwordTooShort) }
        return errors
    }

    private func isValidEmail(_ s: String) -> Bool {
        s.range(of: #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#,
                options: .regularExpression) != nil
    }
}

final class RegistrationViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let stack = UIStackView()

    private let nameField = UITextField.form(placeholder: "Имя")
    private let emailField = UITextField.form(placeholder: "Email")
    private let passwordField = UITextField.form(placeholder: "Пароль")
    private let passwordHint = UILabel()
    private let submitButton = UIButton.primary(title: "Создать аккаунт")

    var onSuccess: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Регистрация"
        setupLayout()
        setupFields()
        setupKeyboardHandling()
    }

    private func setupLayout() {
        view.addSubview(scrollView)
        scrollView.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
        ])

        stack.addArrangedSubview(makeFieldLabel("Имя"))
        stack.addArrangedSubview(nameField)
        stack.addArrangedSubview(makeFieldLabel("Email"))
        stack.addArrangedSubview(emailField)
        stack.addArrangedSubview(makeFieldLabel("Пароль"))
        stack.addArrangedSubview(passwordField)
        stack.addArrangedSubview(passwordHint)
        stack.setCustomSpacing(32, after: passwordHint)
        stack.addArrangedSubview(submitButton)
    }

    private func makeFieldLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 13, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }

    private func setupFields() {
        for field in [nameField, emailField, passwordField] {
            field.delegate = self
            field.addTarget(self, action: #selector(fieldChanged), for: .editingChanged)
        }

        nameField.autocapitalizationType = .words
        nameField.returnKeyType = .next

        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.autocorrectionType = .no
        emailField.returnKeyType = .next

        passwordField.isSecureTextEntry = true
        passwordField.autocapitalizationType = .none
        passwordField.autocorrectionType = .no
        passwordField.returnKeyType = .done
        passwordField.textContentType = .newPassword

        passwordHint.text = "Минимум 8 символов"
        passwordHint.font = .systemFont(ofSize: 12)
        passwordHint.textColor = .secondaryLabel

        submitButton.heightAnchor.constraint(equalToConstant: 52).isActive = true
        submitButton.addTarget(self, action: #selector(submitTapped), for: .touchUpInside)
        submitButton.isEnabled = false
        submitButton.alpha = 0.5
    }

    private func setupKeyboardHandling() {
        scrollView.keyboardDismissMode = .interactive
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func fieldChanged() {
        let form = RegistrationForm(name: nameField.text ?? "",
                                    email: emailField.text ?? "",
                                    password: passwordField.text ?? "")
        let allOK = form.validate().isEmpty
        submitButton.isEnabled = allOK
        submitButton.alpha = allOK ? 1.0 : 0.5
        passwordHint.textColor = (passwordField.text?.count ?? 0) >= 8 ? .systemGreen : .secondaryLabel
    }

    @objc func submitTapped() {
        let form = RegistrationForm(name: nameField.text ?? "",
                                    email: emailField.text ?? "",
                                    password: passwordField.text ?? "")
        guard form.validate().isEmpty else { return }

        submitButton.isEnabled = false
        submitButton.configuration?.title = "Создаём…"

        Task {
            do {
                _ = try await AuthService.shared.register(name: form.name,
                                                          email: form.email,
                                                          password: form.password)
                handleSuccess()
            } catch {
                handleError()
            }
        }
    }

    private func handleSuccess() {
        let alert = UIAlertController(title: "Готово",
                                      message: "Аккаунт создан!",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.onSuccess?()
        })
        present(alert, animated: true)
    }

    private func handleError() {
        submitButton.isEnabled = true
        submitButton.configuration?.title = "Создать аккаунт"

        let alert = UIAlertController(title: "Ошибка",
                                      message: "Не удалось создать аккаунт. Попробуйте ещё раз.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:
            emailField.becomeFirstResponder()
        case emailField:
            passwordField.becomeFirstResponder()
        case passwordField:
            passwordField.resignFirstResponder()
            if submitButton.isEnabled { submitTapped() }
        default:
            break
        }
        return false
    }
}
