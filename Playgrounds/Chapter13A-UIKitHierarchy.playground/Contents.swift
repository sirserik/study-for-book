import Foundation
import CoreGraphics

// Этот Playground моделирует иерархию UIKit через mock-классы,
// потому что в command-line script UIKit недоступен.
// Реальные классы UIKit имеют ту же структуру, только с настоящим UI.

// MARK: - 13A.3 NSObject — корень всего

class MockNSObject {
    func addObserver(_ obs: AnyObject, name: String, action: () -> Void) {
        print("[NSObject] addObserver для name=\(name)")
        // действительно зовёт action для демо
        action()
    }

    func perform(_ method: String) {
        print("[NSObject] perform method=\(method)")
    }

    static func description() -> String {
        return "NSObject — корень иерархии (KVO, runtime, perform)"
    }
}

print("--- 13A.3 NSObject ---")
print(MockNSObject.description())

// MARK: - 13A.4/5 UIResponder — обработка событий

class MockUIResponder: MockNSObject {
    var canBecomeFirstResponder: Bool { false }
    private(set) var isFirstResponder = false

    func becomeFirstResponder() -> Bool {
        guard canBecomeFirstResponder else {
            print("  [\(type(of: self))] becomeFirstResponder failed: canBecome=false")
            return false
        }
        isFirstResponder = true
        print("  [\(type(of: self))] становится first responder")
        return true
    }

    func resignFirstResponder() -> Bool {
        guard isFirstResponder else { return false }
        isFirstResponder = false
        print("  [\(type(of: self))] resign first responder")
        return true
    }

    func touchesBegan() {
        print("  [\(type(of: self))] touchesBegan — низкоуровневое событие")
    }
}

// MARK: - 13A.5 UIView

class MockUIView: MockUIResponder {
    var frame: CGRect = .zero
    var bounds: CGRect = .zero
    var alpha: Double = 1.0
    var isHidden: Bool = false
    var backgroundColor: String = "white"
    weak var superview: MockUIView?
    var subviews: [MockUIView] = []

    override var canBecomeFirstResponder: Bool { false }   // по умолчанию

    func addSubview(_ view: MockUIView) {
        subviews.append(view)
        view.superview = self
    }

    func removeFromSuperview() {
        superview?.subviews.removeAll { $0 === self }
        superview = nil
    }
}

// MARK: - 13A.6 UIView потомки

class MockUILabel: MockUIView {
    var text: String = ""
    var font: String = "system 17"
    // не UIControl — нет target-action
}

class MockUIImageView: MockUIView {
    var imageName: String = ""
    var contentMode: String = "scaleAspectFit"
}

// MARK: - 13A.7 UIScrollView и потомки

class MockUIScrollView: MockUIView {
    var contentSize: CGSize = .zero
    var contentOffset: CGPoint = .zero
    var contentInset: (top: Double, bottom: Double, left: Double, right: Double) = (0, 0, 0, 0)
}

class MockUITableView: MockUIScrollView {
    weak var dataSource: AnyObject?
    weak var delegate: AnyObject?
}

class MockUICollectionView: MockUIScrollView {
    weak var dataSource: AnyObject?
    weak var delegate: AnyObject?
}

// MARK: - 13A.8 UIControl

class MockUIControl: MockUIView {
    var isEnabled: Bool = true
    var isSelected: Bool = false
    var isHighlighted: Bool = false

    private var targets: [(target: AnyObject?, action: () -> Void, event: String)] = []

    func addTarget(_ target: AnyObject?, event: String, action: @escaping () -> Void) {
        targets.append((target, action, event))
        print("  [\(type(of: self))] addTarget event=\(event)")
    }

    func sendActions(for event: String) {
        for (_, action, e) in targets where e == event {
            action()
        }
    }
}

// MARK: - 13A.9 UIControl потомки

class MockUIButton: MockUIControl {
    var title: String = ""

    override var canBecomeFirstResponder: Bool { false }
}

class MockUITextField: MockUIControl {
    var text: String = ""
    var placeholder: String = ""

    override var canBecomeFirstResponder: Bool { true }   // главное отличие!
}

class MockUISwitch: MockUIControl {
    var isOn: Bool = false
}

// MARK: - Демонстрация наследования методов

print("\n--- 13A.5 UIResponder ---")
let label = MockUILabel()
label.text = "Сәлем"
print("UILabel canBecomeFirstResponder:", label.canBecomeFirstResponder)
_ = label.becomeFirstResponder()       // не получится — canBecome=false

print("\n--- 13A.6 UIView frame/bounds ---")
let view = MockUIView()
view.frame = CGRect(x: 50, y: 100, width: 200, height: 80)
view.bounds = CGRect(x: 0, y: 0, width: 200, height: 80)
print("frame:", view.frame)
print("bounds:", view.bounds)
print("backgroundColor:", view.backgroundColor)

view.addSubview(label)
print("subviews count:", view.subviews.count)
print("label.superview is view:", label.superview === view)

print("\n--- 13A.7 UIScrollView потомки ---")
let table = MockUITableView()
table.contentSize = CGSize(width: 320, height: 2000)
table.contentOffset = CGPoint(x: 0, y: 500)
print("UITableView contentSize:", table.contentSize)
print("UITableView contentOffset:", table.contentOffset)
// проверяем «is-a» через приведение к Any — компилятор не статически знает иерархию
let tableAsAny: Any = table
print("UITableView это UIScrollView?", tableAsAny is MockUIScrollView)
print("UITableView это UIView?", tableAsAny is MockUIView)
print("UITableView это UIResponder?", tableAsAny is MockUIResponder)
print("UITableView это NSObject?", tableAsAny is MockNSObject)

print("\n--- 13A.8 UIControl target-action ---")
let button = MockUIButton()
button.title = "Войти"
button.addTarget(nil, event: "touchUpInside") {
    print("  → нажата кнопка \(button.title)")
}

print("Симулируем тап:")
button.sendActions(for: "touchUpInside")

let toggle = MockUISwitch()
toggle.addTarget(nil, event: "valueChanged") {
    toggle.isOn.toggle()
    print("  → switch теперь:", toggle.isOn ? "on" : "off")
}
toggle.sendActions(for: "valueChanged")
toggle.sendActions(for: "valueChanged")

print("\n--- UITextField vs UILabel ---")
let textField = MockUITextField()
textField.placeholder = "Email"
print("UITextField canBecomeFirstResponder:", textField.canBecomeFirstResponder)
_ = textField.becomeFirstResponder()       // получится!
_ = textField.resignFirstResponder()

let labelToo = MockUILabel()
print("UILabel canBecomeFirstResponder:", labelToo.canBecomeFirstResponder)
// labelToo.addTarget — ошибка компиляции, нет метода у UILabel

// MARK: - 13A.10 UIView vs UIControl

print("\n--- 13A.10 разница UIView и UIControl ---")
let labelAny: Any = label
let buttonAny: Any = button
let textFieldAny: Any = textField
print("UILabel это UIControl?", labelAny is MockUIControl)        // false
print("UIButton это UIControl?", buttonAny is MockUIControl)      // true
print("UITextField это UIControl?", textFieldAny is MockUIControl) // true

// MARK: - 13A.11 UIViewController — отдельная иерархия

class MockUIViewController: MockUIResponder {
    var view: MockUIView?

    override var canBecomeFirstResponder: Bool { true }

    func loadView() {
        view = MockUIView()
        print("  [VC] loadView создал view")
    }
}

print("\n--- 13A.11 UIViewController ---")
let vc = MockUIViewController()
let vcAny: Any = vc
print("UIViewController это UIResponder?", vcAny is MockUIResponder)
print("UIViewController это UIView?", vcAny is MockUIView)        // false!
vc.loadView()
print("vc.view не nil:", vc.view != nil)
let viewAny: Any = vc.view as Any
print("vc.view это UIView?", viewAny is MockUIView)            // true

// MARK: - Большое упражнение 13A.3: RoundedTagView mock

class MockRoundedTagView: MockUIView {
    let tagText: String
    let tagColor: String
    private let internalLabel: MockUILabel

    init(text: String, color: String) {
        self.tagText = text
        self.tagColor = color
        self.internalLabel = MockUILabel()
        super.init()
        backgroundColor = color
        // в реальном UIView был бы layer.cornerRadius
        internalLabel.text = text
        addSubview(internalLabel)
    }

    var intrinsicContentSize: CGSize {
        let labelWidth = Double(tagText.count) * 8.0
        return CGSize(width: labelWidth + 24, height: 24)
    }
}

print("\n--- 13A.3 RoundedTagView ---")
let tag = MockRoundedTagView(text: "iOS", color: "blue")
print("tag text:", tag.tagText)
print("tag color:", tag.tagColor)
let tagAny: Any = tag
print("tag это UIView?", tagAny is MockUIView)
print("intrinsic size:", tag.intrinsicContentSize)
print("subviews count:", tag.subviews.count)

print("\n--- Done ---")
