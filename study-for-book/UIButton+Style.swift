import UIKit

extension UIButton {
    /// Главная кнопка экрана: синяя плашка со скруглёнными углами.
    static func primary(title: String) -> UIButton {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = title
        config.cornerStyle = .medium
        config.buttonSize = .large
        button.configuration = config
        return button
    }
}
