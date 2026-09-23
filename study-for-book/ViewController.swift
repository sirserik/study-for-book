import UIKit

class ViewController: UIViewController {

    private let counterLabel = UILabel()
    private let tapButton = UIButton(type: .system)
    private var tapCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // настройка counterLabel
        counterLabel.text = "Нажатий: 0"
        counterLabel.font = .preferredFont(forTextStyle: .title2)
        counterLabel.textAlignment = .center

        // настройка tapButton
        var config = UIButton.Configuration.filled()
        config.title = "Тап!"
        config.cornerStyle = .medium
        tapButton.configuration = config
        tapButton.addTarget(self, action: #selector(didTap), for: .touchUpInside)

        // добавляем в иерархию
        [counterLabel, tapButton].forEach {
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // constraints
        NSLayoutConstraint.activate([
            counterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            counterLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -32),

            tapButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tapButton.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 24),
            tapButton.widthAnchor.constraint(equalToConstant: 200),
            tapButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func didTap() {
        tapCount += 1
        counterLabel.text = "Нажатий: \(tapCount)"
    }
}
