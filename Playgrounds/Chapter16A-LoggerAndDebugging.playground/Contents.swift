import Foundation

// Глава 16A: Logger и отладка.
// Реальный os.Logger требует import OSLog и доступен только
// внутри iOS/macOS-приложения с Bundle. В command-line script
// моделируем API через mock-логер.

// MARK: - 16A.2 Mock Logger API (повторяет Apple's Logger)

enum LogLevel: Int, Comparable {
    case debug = 0, info, notice, warning, error, critical, fault

    var label: String {
        switch self {
        case .debug:    return "DEBUG"
        case .info:     return "INFO"
        case .notice:   return "NOTICE"
        case .warning:  return "WARNING"
        case .error:    return "ERROR"
        case .critical: return "CRITICAL"
        case .fault:    return "FAULT"
        }
    }

    static func < (a: LogLevel, b: LogLevel) -> Bool {
        return a.rawValue < b.rawValue
    }
}

enum Privacy {
    case `public`
    case `private`
    case sensitive
}

struct MockLogger {
    let subsystem: String
    let category: String

    // В Release минимальный уровень — notice. В Debug — debug.
    static var minLevel: LogLevel = {
        #if DEBUG
        return .debug
        #else
        return .notice
        #endif
    }()

    static var redactPrivate: Bool = {
        #if DEBUG
        return false
        #else
        return true
        #endif
    }()

    func write(_ level: LogLevel, _ message: String) {
        guard level >= MockLogger.minLevel else { return }
        let timestamp = ISO8601DateFormatter().string(from: Date())
        print("[\(timestamp)] [\(level.label)] [\(subsystem)/\(category)] \(message)")
    }

    func debug(_ message: String) { write(.debug, message) }
    func info(_ message: String) { write(.info, message) }
    func notice(_ message: String) { write(.notice, message) }
    func warning(_ message: String) { write(.warning, message) }
    func error(_ message: String) { write(.error, message) }
    func critical(_ message: String) { write(.critical, message) }
    func fault(_ message: String) { write(.fault, message) }
}

// Утилита для имитации privacy markers (\(value, privacy: .private))
func privacy(_ value: Any, _ marker: Privacy) -> String {
    switch marker {
    case .public:
        return "\(value)"
    case .private:
        return MockLogger.redactPrivate ? "<private>" : "\(value)"
    case .sensitive:
        return "<sensitive>"
    }
}

// MARK: - Categories

extension MockLogger {
    static let subsystem = "kz.shopapp.beginner"

    static let network = MockLogger(subsystem: subsystem, category: "Network")
    static let auth = MockLogger(subsystem: subsystem, category: "Auth")
    static let cart = MockLogger(subsystem: subsystem, category: "Cart")
    static let payment = MockLogger(subsystem: subsystem, category: "Payment")
    static let ui = MockLogger(subsystem: subsystem, category: "UI")
}

// MARK: - 16A.2/3 Уровни и категории

print("--- 16A.3 Уровни логирования ---")
MockLogger.minLevel = .debug   // показываем все

MockLogger.network.debug("Готовим запрос к /api/products")
MockLogger.network.info("Запрос отправлен")
MockLogger.network.notice("Получили 200 OK")
MockLogger.network.warning("Ответ замедлен (1.5 секунды)")
MockLogger.network.error("Не удалось распарсить product[id=42]")
MockLogger.network.fault("Сетевой сервис вернул невалидный JSON")

print("\n--- 16A.3 В Release минимальный уровень notice ---")
MockLogger.minLevel = .notice
MockLogger.network.debug("Этот debug не попадёт в лог в Release")
MockLogger.network.info("Этот info тоже не попадёт")
MockLogger.network.notice("А notice попадёт")
MockLogger.network.error("И error тоже")
MockLogger.minLevel = .debug   // вернули обратно

// MARK: - 16A.4 Privacy markers

print("\n--- 16A.4 Privacy markers ---")

let userId = 42
let userName = "Айгерим"
let userEmail = "ai@example.kz"

print("Сценарий DEBUG (показываем приватные значения):")
MockLogger.redactPrivate = false
MockLogger.auth.info("ID=\(privacy(userId, .public)) name=\(privacy(userName, .private)) email=\(privacy(userEmail, .private))")

print("\nСценарий RELEASE (privacy скрывает):")
MockLogger.redactPrivate = true
MockLogger.auth.info("ID=\(privacy(userId, .public)) name=\(privacy(userName, .private)) email=\(privacy(userEmail, .private))")

print("\nSensitive — скрыто всегда:")
let cardNumber = "4242 4242 4242 4242"
MockLogger.redactPrivate = false
MockLogger.payment.info("CC=\(privacy(cardNumber, .sensitive))")

// MARK: - 16A.6 Format specifiers

print("\n--- 16A.6 Форматирование чисел ---")

extension Double {
    var fixed2: String {
        return String(format: "%.2f", self)
    }
}

extension Int {
    var hex: String {
        return String(format: "0x%X", self)
    }
}

let price = 1234.5678
let count = 256
MockLogger.cart.info("Цена точная: \(price)")
MockLogger.cart.info("Цена 2 знака: \(price.fixed2)")
MockLogger.cart.info("Количество: \(count)")
MockLogger.cart.info("Hex: \(count.hex)")

// MARK: - 16A.7 debugPrint helper

print("\n--- 16A.7 debugPrint helper ---")

@inlinable
func debugLog(_ message: String,
              file: String = #file,
              line: Int = #line,
              function: String = #function) {
    #if DEBUG
    let filename = (file as NSString).lastPathComponent
    print("[debug] \(filename):\(line) \(function) → \(message)")
    #endif
}

debugLog("В Debug это видно")
// В Release вызов исчезает из бинарника

// MARK: - 16A.13 Логирование с context

print("\n--- 16A.13 Context vs no context ---")

// плохо
MockLogger.cart.error("Failed")

// хорошо
let productId = 42
let cartError = "Database timeout"
MockLogger.cart.error("Не добавил продукт \(privacy(productId, .public)): \(privacy(cartError, .public))")

// MARK: - 16A.8 Эмуляция conditional breakpoint в коде

print("\n--- 16A.8 Эмуляция conditional breakpoint ---")
print("Поставить breakpoint на условие i == 50 — это IDE-функция, в коде эквивалент:")

let products = (1...100).map { "P\($0)" }
for (i, p) in products.enumerated() {
    if i == 50 {
        // здесь IDE-debugger остановился бы автоматически
        // в коде мы можем сэмулировать через лог
        MockLogger.cart.warning("⚠ Breakpoint условие сработало: i=\(i), product=\(p)")
    }
    // в реальной отладке тут не нужно ничего, но для демо:
    // MockLogger.cart.debug("processing \(p)")  // забивает лог
}

// MARK: - 16A.11 Эмуляция retain cycle (для Memory Graph упражнения)

print("\n--- 16A.11 Демо retain cycle (мы видели это в главе 11B) ---")

class Owner {
    var onChange: (() -> Void)?
    let id: String

    init(id: String) {
        self.id = id
        print("Owner '\(id)' создан")
    }

    deinit {
        print("Owner '\(id)' освобождён")
    }
}

print("\nСценарий с CYCLE (плохой):")
do {
    let owner = Owner(id: "leaky")
    // self захватывается strongly
    owner.onChange = {
        print("  callback от \(owner.id)")
    }
    owner.onChange?()
}   // deinit не должен сработать

print("\nСценарий с [weak self] (хороший):")
do {
    let owner = Owner(id: "ok")
    owner.onChange = { [weak owner] in
        guard let owner else { return }
        print("  callback от \(owner.id)")
    }
    owner.onChange?()
}   // deinit срабатывает

print("\n--- 16A — Done ---")
