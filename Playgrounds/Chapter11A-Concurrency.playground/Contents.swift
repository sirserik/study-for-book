import Foundation

// Примечание про запуск. Верхний уровень скрипта в режиме Swift 6 — это
// MainActor, и `await` здесь работает напрямую: `let x = await foo()`.
// Именно так тут всё и написано.
//
// Чего делать НЕЛЬЗЯ: запускать Task { } и ждать его через
// DispatchGroup.wait() или семафор. Ожидание блокирует главный поток,
// а Task, унаследовавший MainActor, ждёт освобождения этого же потока —
// программа зависает навсегда. Это классический дедлок, и раньше в этом
// файле он был.

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
let result = await processChain()
print("result:", result)

// MARK: - 11A.5/6 Task и порядок выполнения

print("--- 11A.5/6 Task ---")
// Task { } запускается «в сторону»: код после него выполняется сразу,
// не дожидаясь тела задачи. Чтобы дождаться результата — сохраняем
// задачу и берём её .value.
let t56 = Task {
    print("в Task: 1")
    let data = await loadFromServer()
    print("в Task: 2 ->", data)
}
print("после Task() (главный поток продолжил)")
await t56.value

// MARK: - 11A.7 Task value

print("--- 11A.7 task.value ---")
let valueTask = Task { return await loadFromServer() }
let v = await valueTask.value
print("task.value:", v)

// MARK: - 11A.8 @MainActor

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
// Верхний уровень скрипта уже на главном акторе, поэтому обращаемся
// к @MainActor-классу напрямую, без await и без обходных приёмов.
let vm = HomeVM()
vm.reload()
print("products:", vm.products)
print("isLoading:", vm.isLoading)

// MARK: - 11A.9 MainActor.run

// MainActor.run нужен, когда мы ТОЧНО не на главном акторе — например,
// внутри Task.detached. Проверяем это на практике.
func heavyCalculation() -> Int {
    (1...1_000_000).reduce(0, +)
}

print("--- 11A.9 MainActor.run ---")
let detached = Task.detached {
    // считаем в фоне, главный поток свободен
    let sum = heavyCalculation()
    await MainActor.run {
        // а здесь мы уже на главном акторе — тут можно трогать UI
        print("на главном акторе, сумма:", sum)
    }
}
await detached.value

// MARK: - 11A.10 nonisolated

@MainActor
final class FormatterClass {
    var counter: Int = 0
    nonisolated func formatPrice(_ price: Int) -> String {
        return "\(price) ₸"
    }
}

print("--- 11A.10 nonisolated ---")
let f = FormatterClass()
print(f.formatPrice(1500))

// MARK: - 11A.11 Task.sleep

print("--- 11A.11 Task.sleep ---")
print("До sleep")
let sleepStart = Date()
try await Task.sleep(for: .milliseconds(300))
let sleepElapsed = Date().timeIntervalSince(sleepStart)
print("Прошло:", String(format: "%.2f", sleepElapsed), "сек")

// MARK: - 11A.12 Cancellation

func longWork() async throws -> Int {
    for _ in 1...10 {
        try Task.checkCancellation()
        try await Task.sleep(for: .milliseconds(50))
    }
    return 42
}

print("--- 11A.12 Cancellation ---")
let cancellableTask = Task<Int, Error> {
    return try await longWork()
}
try? await Task.sleep(for: .milliseconds(100))
cancellableTask.cancel()
do {
    let r = try await cancellableTask.value
    print("результат:", r)
} catch is CancellationError {
    print("Отменена через 100мс")
} catch {
    print("Ошибка:", error)
}

// MARK: - 11A.13 async let

func loadUser() async -> String { "Айдос" }
func loadProducts() async -> [String] { ["Латте", "Раф"] }
func loadOrders() async -> [String] { ["ORD-001", "ORD-002"] }

print("--- 11A.13 async let ---")
let parallelStart = Date()
async let user = loadUser()
async let products = loadProducts()
async let orders = loadOrders()

let (u, p, o) = await (user, products, orders)
let parallelElapsed = Date().timeIntervalSince(parallelStart)
print("user:", u)
print("products:", p)
print("orders:", o)
print("параллельно за", String(format: "%.3f", parallelElapsed), "сек")

// MARK: - 11A.14 TaskGroup

func fetchValue(_ id: Int) async -> Int {
    try? await Task.sleep(for: .milliseconds(20))
    return id * 10
}

print("--- 11A.14 TaskGroup ---")
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

print("в Task.detached:", prod.title, prod.price, "₸")
print("config:", cfg.baseURL)

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
let account = BankAccount()
await account.deposit(1500)
await account.deposit(500)
let ok = await account.withdraw(800)
print("withdraw 800:", ok)
print("balance:", await account.getBalance(), "₸")

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
do {
    let items = try await loadAsync()
    print("loaded async:", items)
} catch {
    print("error:", error)
}

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
do {
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
}

print("--- Done ---")
