import Foundation

// Примечание: командная строка `swift Contents.swift` имеет особенности.
// Главный поток (на котором мы здесь печатаем) — это MainActor. Если мы
// делаем Task { } и ждём через g.wait(), main блокируется — Task'и
// без @MainActor работают в фоне, но Task с @MainActor / MainActor.run
// внутри уже не могут попасть на занятый main thread → deadlock.
//
// Поэтому в этом Playground:
// 1) MainActor-демонстрации делаем синхронно через MainActor.assumeIsolated.
// 2) Task'и без MainActor запускаем без waiting.
// 3) В конце Thread.sleep даём Task'ам время дозаписать вывод.

// MARK: - 11A.4 async/await

func loadFromServer() async -> String {
    try? await Task.sleep(for: .milliseconds(50))
    return "data"
}

func processChain() async -> String {
    let raw = await loadFromServer()
    return raw.uppercased()
}

print("--- 11A.4 async/await ---")
let g4 = DispatchGroup()
g4.enter()
Task {
    let result = await processChain()
    print("result:", result)
    g4.leave()
}
g4.wait()

// MARK: - 11A.5/6 Task и порядок выполнения

print("--- 11A.5/6 Task ---")
let g5 = DispatchGroup()
g5.enter()
Task {
    print("в Task: 1")
    let data = await loadFromServer()
    print("в Task: 2 ->", data)
    g5.leave()
}
print("после Task() (main thread продолжил)")
g5.wait()

// MARK: - 11A.7 Task value

print("--- 11A.7 task.value ---")
let g7 = DispatchGroup()
g7.enter()
Task {
    let task = Task { return await loadFromServer() }
    let v = await task.value
    print("task.value:", v)
    g7.leave()
}
g7.wait()

// MARK: - 11A.8 @MainActor (синхронно через assumeIsolated)

@MainActor
final class HomeVM {
    var products: [String] = []
    var isLoading: Bool = false

    func reload() {
        // упрощённо синхронно для демо
        products = ["Латте", "Раф", "Капучино"]
        isLoading = false
    }
}

print("--- 11A.8 @MainActor ---")
MainActor.assumeIsolated {
    let vm = HomeVM()
    vm.reload()
    print("products:", vm.products)
    print("isLoading:", vm.isLoading)
}

// MARK: - 11A.9 MainActor.run
// В обычном iOS-приложении MainActor.run внутри Task переключает на main:
//
//   Task {
//       let data = await loadFromServer()        // background
//       await MainActor.run {
//           self.tableView.reloadData()           // main — для UI
//       }
//   }
//
// В скрипте `swift Contents.swift` это вызывает деадлок: g.wait()
// блокирует main, MainActor.run хочет main → ждут друг друга.
// Поэтому здесь демонстрируем только синтаксис.

print("--- 11A.9 MainActor.run (синтаксис) ---")
print("await MainActor.run { ... } — переход на main изнутри Task")

// MARK: - 11A.10 nonisolated

@MainActor
final class FormatterClass {
    var counter: Int = 0
    nonisolated func formatPrice(_ price: Int) -> String {
        return "\(price) ₸"
    }
}

print("--- 11A.10 nonisolated ---")
MainActor.assumeIsolated {
    let f = FormatterClass()
    print(f.formatPrice(1500))
}

// MARK: - 11A.11 Task.sleep

print("--- 11A.11 Task.sleep ---")
let g11 = DispatchGroup()
g11.enter()
Task {
    print("До sleep")
    let start = Date()
    try await Task.sleep(for: .milliseconds(300))
    let elapsed = Date().timeIntervalSince(start)
    print("Прошло:", String(format: "%.2f", elapsed), "сек")
    g11.leave()
}
g11.wait()

// MARK: - 11A.12 Cancellation

func longWork() async throws -> Int {
    for _ in 1...10 {
        try Task.checkCancellation()
        try await Task.sleep(for: .milliseconds(50))
    }
    return 42
}

print("--- 11A.12 Cancellation ---")
let g12 = DispatchGroup()
g12.enter()
Task {
    let task = Task<Int, Error> {
        return try await longWork()
    }
    try? await Task.sleep(for: .milliseconds(100))
    task.cancel()
    do {
        let r = try await task.value
        print("результат:", r)
    } catch is CancellationError {
        print("Отменена через 100мс")
    } catch {
        print("Ошибка:", error)
    }
    g12.leave()
}
g12.wait()

// MARK: - 11A.13 async let

func loadUser() async -> String { "Айдос" }
func loadProducts() async -> [String] { ["Латте", "Раф"] }
func loadOrders() async -> [String] { ["ORD-001", "ORD-002"] }

print("--- 11A.13 async let ---")
let g13 = DispatchGroup()
g13.enter()
Task {
    let start = Date()
    async let user = loadUser()
    async let products = loadProducts()
    async let orders = loadOrders()

    let (u, p, o) = await (user, products, orders)
    let elapsed = Date().timeIntervalSince(start)
    print("user:", u)
    print("products:", p)
    print("orders:", o)
    print("параллельно за", String(format: "%.3f", elapsed), "сек")
    g13.leave()
}
g13.wait()

// MARK: - 11A.14 TaskGroup

func fetchValue(_ id: Int) async -> Int {
    try? await Task.sleep(for: .milliseconds(20))
    return id * 10
}

print("--- 11A.14 TaskGroup ---")
let g14 = DispatchGroup()
g14.enter()
Task {
    let results = await withTaskGroup(of: Int.self) { group in
        for id in 1...5 {
            group.addTask { return await fetchValue(id) }
        }
        var collected: [Int] = []
        for await result in group {
            collected.append(result)
        }
        return collected.sorted()
    }
    print("TaskGroup results:", results)
    g14.leave()
}
g14.wait()

// MARK: - 11A.16 Sendable

struct ProductSendable: Sendable {
    let id: Int
    let title: String
    let price: Int
}

final class APIConfig: Sendable {
    let baseURL: String
    let timeout: Int
    init(baseURL: String, timeout: Int) {
        self.baseURL = baseURL
        self.timeout = timeout
    }
}

print("--- 11A.16 Sendable ---")
let prod = ProductSendable(id: 1, title: "Латте", price: 1200)
let cfg = APIConfig(baseURL: "https://shop.example.kz", timeout: 30)

let g16 = DispatchGroup()
g16.enter()
Task.detached {
    print("в Task.detached:", prod.title, prod.price, "₸")
    print("config:", cfg.baseURL)
    g16.leave()
}
g16.wait()

// MARK: - 11A.17 actor

actor BankAccount {
    private var balance: Int = 0
    func deposit(_ amount: Int) { balance += amount }
    func withdraw(_ amount: Int) -> Bool {
        if balance < amount { return false }
        balance -= amount
        return true
    }
    func getBalance() -> Int { balance }
}

print("--- 11A.17 actor ---")
let g17 = DispatchGroup()
g17.enter()
Task {
    let account = BankAccount()
    await account.deposit(1500)
    await account.deposit(500)
    let ok = await account.withdraw(800)
    print("withdraw 800:", ok)
    print("balance:", await account.getBalance(), "₸")
    g17.leave()
}
g17.wait()

// MARK: - 11A.20 withCheckedContinuation

func legacyLoad(completion: @escaping (Result<[String], Error>) -> Void) {
    DispatchQueue.global().async {
        Thread.sleep(forTimeInterval: 0.05)
        completion(.success(["one", "two", "three"]))
    }
}

func loadAsync() async throws -> [String] {
    return try await withCheckedThrowingContinuation { continuation in
        legacyLoad { result in
            switch result {
            case .success(let items):
                continuation.resume(returning: items)
            case .failure(let error):
                continuation.resume(throwing: error)
            }
        }
    }
}

print("--- 11A.20 withCheckedContinuation ---")
let g20 = DispatchGroup()
g20.enter()
Task {
    do {
        let items = try await loadAsync()
        print("loaded async:", items)
    } catch {
        print("error:", error)
    }
    g20.leave()
}
g20.wait()

// MARK: - Большое упражнение 11A.1: DataLoader actor

enum LoaderError: Error {
    case empty
}

actor DataLoader {
    private var cache: [String: Data] = [:]

    func load(_ key: String) async throws -> Data {
        try Task.checkCancellation()
        if let cached = cache[key] {
            return cached
        }
        try await Task.sleep(for: .milliseconds(50))
        try Task.checkCancellation()

        let data = key.data(using: .utf8) ?? Data()
        guard !data.isEmpty else { throw LoaderError.empty }
        cache[key] = data
        return data
    }

    func clearCache() { cache.removeAll() }
    func cacheCount() -> Int { cache.count }
}

print("--- 11A.1 DataLoader actor ---")
let gA1 = DispatchGroup()
gA1.enter()
Task {
    let loader = DataLoader()
    let start = Date()
    let d1 = try await loader.load("hello")
    let t1 = Date().timeIntervalSince(start)

    let start2 = Date()
    _ = try await loader.load("hello")
    let t2 = Date().timeIntervalSince(start2)

    print("первая загрузка:", String(format: "%.3f", t1), "сек, размер:", d1.count, "байт")
    print("из кэша:", String(format: "%.4f", t2), "сек (мгновенно)")
    print("в кэше:", await loader.cacheCount(), "элемент(ов)")

    let task = Task<Data, Error> {
        return try await loader.load("big-data")
    }
    try? await Task.sleep(for: .milliseconds(20))
    task.cancel()
    do {
        let _ = try await task.value
    } catch is CancellationError {
        print("отменили — CancellationError")
    } catch {
        print("error:", error)
    }
    gA1.leave()
}
gA1.wait()

print("--- Done ---")
