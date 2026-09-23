import UIKit

class ViewController: UIViewController {

    private var tapCount = 0
    private let counterLabel = UILabel()
    private let button = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Лейбл со счётчиком
        counterLabel.text = "Нажатий: 0"
        counterLabel.font = .boldSystemFont(ofSize: 28)
        counterLabel.textAlignment = .center

        // Кнопка
        button.setTitle("Нажми", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)

        // Стек
        let stack = UIStackView(arrangedSubviews: [counterLabel, button])
        stack.axis = .vertical
        stack.spacing = 24
        stack.alignment = .center

        view.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            button.widthAnchor.constraint(equalToConstant: 200),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func didTapButton() {
        tapCount += 1
        counterLabel.text = "Нажатий: \(tapCount)"
    }
}
