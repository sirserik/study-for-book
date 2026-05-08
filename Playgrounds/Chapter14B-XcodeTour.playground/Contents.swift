import Foundation

// Глава 14B: Тур по Xcode 16.
// Демо API, которые часто используются в скриптах
// инициализации приложения и в отладке:
// - CommandLine.arguments (передаются через Scheme → Run → Arguments)
// - ProcessInfo.processInfo.environment (Scheme → Run → Environment)
// - Build configuration (#if DEBUG / #if RELEASE)

// MARK: - 14B.8 CommandLine.arguments

print("--- 14B.8 CommandLine.arguments ---")
print("Количество аргументов: \(CommandLine.arguments.count)")
for (i, arg) in CommandLine.arguments.enumerated() {
    print("  [\(i)] \(arg)")
}
// arguments[0] — путь к бинарнику.
// arguments[1...] — переданные через Scheme или из терминала.

// Симулируем флаг -ShowDebugMenu
let isDebugMenuRequested = CommandLine.arguments.contains("-ShowDebugMenu")
print("\nDebug menu активирован: \(isDebugMenuRequested)")

// Парсинг -Param value
func argumentValue(for key: String) -> String? {
    let args = CommandLine.arguments
    guard let idx = args.firstIndex(of: key), idx + 1 < args.count else {
        return nil
    }
    return args[idx + 1]
}

if let server = argumentValue(for: "-APIServer") {
    print("API server из аргументов: \(server)")
} else {
    print("Аргумент -APIServer не передан, fallback: https://api.shopapp.kz")
}

// MARK: - 14B.13 ProcessInfo.environment

print("\n--- 14B.13 ProcessInfo.environment ---")
let env = ProcessInfo.processInfo.environment

// Полезные системные переменные
if let home = env["HOME"] {
    print("HOME: \(home)")
}
if let user = env["USER"] {
    print("USER: \(user)")
}
if let path = env["PATH"]?.split(separator: ":").prefix(3) {
    print("PATH (первые 3): \(Array(path))")
}

// Кастомные переменные из Scheme → Environment Variables
let apiToken = env["API_TOKEN"] ?? "<не задан>"
let logLevel = env["LOG_LEVEL"] ?? "info"
print("API_TOKEN: \(apiToken)")
print("LOG_LEVEL: \(logLevel)")

// MARK: - 14B.13 Build configuration

print("\n--- 14B.13 Build configuration (#if DEBUG) ---")
#if DEBUG
print("Это DEBUG сборка")
print("  Здесь работают print, assertions, можно использовать сетевые mock'и")
let isDebug = true
#else
print("Это RELEASE сборка")
print("  Print не должен использоваться, assertions удалены")
let isDebug = false
#endif

// MARK: - Полезный API ProcessInfo

print("\n--- 14B Полезный API ProcessInfo ---")
let processInfo = ProcessInfo.processInfo
print("processName: \(processInfo.processName)")
print("processIdentifier (PID): \(processInfo.processIdentifier)")
print("operatingSystemVersionString: \(processInfo.operatingSystemVersionString)")
print("hostName: \(processInfo.hostName)")
print("activeProcessorCount: \(processInfo.activeProcessorCount)")

let memBytes = processInfo.physicalMemory
let memGB = Double(memBytes) / (1024 * 1024 * 1024)
print("physicalMemory: \(String(format: "%.1f", memGB)) ГБ")

let uptime = processInfo.systemUptime
print("systemUptime (от загрузки): \(Int(uptime)) секунд")

// MARK: - Bundle.main info

print("\n--- 14B Bundle.main ---")
let bundle = Bundle.main
if let bundleId = bundle.bundleIdentifier {
    print("bundleIdentifier: \(bundleId)")
}
print("bundlePath: \(bundle.bundlePath)")

// В реальном iOS-приложении ещё доступны:
// CFBundleShortVersionString — версия для пользователей (1.0)
// CFBundleVersion — build number (42)
// Тут в командной строке этих ключей нет, но в реальном Info.plist они есть.

// MARK: - Логирование с уровнями (заготовка)

enum LogLevel: String {
    case debug = "DEBUG"
    case info = "INFO"
    case warn = "WARN"
    case error = "ERROR"
}

func log(_ level: LogLevel, _ message: String,
         file: String = #file,
         line: Int = #line,
         function: String = #function) {
    let filename = (file as NSString).lastPathComponent
    print("[\(level.rawValue)] \(filename):\(line) \(function): \(message)")
}

print("\n--- 14B Логирование (литералы #file/#line/#function) ---")
log(.debug, "Старт приложения")
log(.info, "API_TOKEN: \(apiToken == "<не задан>" ? "missing" : "set")")
log(.warn, "Новая фича всё ещё в beta")
log(.error, "Failed to load user profile")

// MARK: - Условная инициализация (DEBUG vs RELEASE)

func setupAPIClient() -> String {
    let baseURL: String
    #if DEBUG
    baseURL = "https://staging-api.shopapp.kz"
    #else
    baseURL = "https://api.shopapp.kz"
    #endif
    return baseURL
}

print("\n--- 14B setupAPIClient ---")
print("base URL: \(setupAPIClient())")
print("isDebug = \(isDebug)")

// MARK: - Проверка Apple-style preconditions

print("\n--- 14B preconditions (только в DEBUG) ---")

func computeAverage(_ values: [Int]) -> Int {
    assert(!values.isEmpty, "Нельзя вычислить average пустого массива")
    precondition(!values.isEmpty, "Нельзя вычислить average пустого массива (даже в Release)")
    return values.reduce(0, +) / values.count
}

let avg = computeAverage([100, 200, 300])
print("Среднее: \(avg)")
// computeAverage([]) — упадёт с assert/precondition

print("\n--- Done ---")
