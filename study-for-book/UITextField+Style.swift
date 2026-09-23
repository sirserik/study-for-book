import UIKit

extension UITextField {
    /// Поле формы: скруглённая рамка, стандартный шрифт, высота 44.
    static func form(placeholder: String) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.borderStyle = .roundedRect
        field.font = .systemFont(ofSize: 17)
        field.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return field
    }
}
