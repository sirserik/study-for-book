import Foundation

// MARK: - 4A.2 Свой Error enum

enum APIError: Error {
    case unauthorized
    case notFound(resource: String)
    case serverError(statusCode: Int)
    case networkError(underlying: Error)
}

// MARK: - 4A.3 throws

enum ValidationError: Error {
    case negative
    case tooBig
}

func validateAge(_ age: Int) throws -> Int {
    if age < 0 { throw ValidationError.negative }
    if age > 150 { throw ValidationError.tooBig }
    return age
}

print("--- 4A.3 throws ---")
do {
    let v = try validateAge(25)
    print("OK:", v)
} catch {
    print("Ошибка:", error)
}

// MARK: - 4A.4 do/try/catch

print("--- 4A.4 do/catch ---")
do {
    let v = try validateAge(-5)
    print("OK:", v)
} catch {
    print("Поймали:", error)
}

// MARK: - 4A.5 try?

print("--- 4A.5 try? ---")
let r1 = try? validateAge(25)
let r2 = try? validateAge(-5)
print("r1:", r1 ?? -1)
print("r2:", r2 ?? -1)

// MARK: - 4A.7 Pattern matching

enum LoginError: Error {
    case wrongPassword
    case userBlocked
    case networkUnavailable
}

func login(password: String) throws -> String {
    if password == "blocked" { throw LoginError.userBlocked }
    if password == "no_net" { throw LoginError.networkUnavailable }
    if password != "secret" { throw LoginError.wrongPassword }
    return "token-abc"
}

print("--- 4A.7 Pattern matching ---")
for pw in ["wrong", "blocked", "no_net", "secret"] {
    do {
        let token = try login(password: pw)
        print("OK:", token)
    } catch LoginError.wrongPassword {
        print("Неверный пароль")
    } catch LoginError.userBlocked {
        print("Аккаунт заблокирован")
    } catch LoginError.networkUnavailable {
        print("Нет соединения")
    } catch {
        print("Другое:", error)
    }
}

// associated values + where
func loadData(statusCode: Int) throws -> String {
    if statusCode != 200 {
        throw APIError.serverError(statusCode: statusCode)
    }
    return "data"
}

print("--- where ---")
for code in [200, 404, 503] {
    do {
        let d = try loadData(statusCode: code)
        print("OK:", d)
    } catch APIError.serverError(let c) where c >= 500 {
        print("Сервер не работает (\(c))")
    } catch APIError.serverError(let c) {
        print("Сервер вернул \(c)")
    } catch {
        print("Другое:", error)
    }
}

// MARK: - 4A.8 Result

print("--- 4A.8 Result ---")
let r = Result { try validateAge(42) }
switch r {
case .success(let v): print("OK:", v)
case .failure(let e): print("Fail:", e)
}

let bad = Result { try validateAge(-3) }
switch bad {
case .success(let v): print("OK:", v)
case .failure(let e): print("Fail:", e)
}

// конверсия результата в throws
do {
    let v = try r.get()
    print("get():", v)
} catch {
    print("get() error:", error)
}

// MARK: - 4A.10 Throwing init

struct Email {
    let value: String

    init(_ value: String) throws {
        guard value.contains("@") else {
            throw ValidationError.tooBig    // используем существующий enum для демо
        }
        self.value = value
    }
}

print("--- 4A.10 throwing init ---")
do {
    let e = try Email("aidos@example.kz")
    print("Email:", e.value)
} catch {
    print("error:", error)
}

do {
    let e = try Email("not_email")
    print("Email:", e.value)
} catch {
    print("error: not an email")
}

// MARK: - 4A.11 LocalizedError

enum TimeError: LocalizedError {
    case empty
    case invalidFormat
    case invalidHours
    case invalidMinutes

    var errorDescription: String? {
        switch self {
        case .empty:
            return "Время не указано"
        case .invalidFormat:
            return "Время должно быть в формате HH:MM"
        case .invalidHours:
            return "Часы должны быть в диапазоне 0–23"
        case .invalidMinutes:
            return "Минуты должны быть в диапазоне 0–59"
        }
    }
}

print("--- 4A.11 LocalizedError ---")
let err = TimeError.invalidHours
print(err.localizedDescription)

// MARK: - 4A.13 defer

func processFile() throws -> String {
    print("открываем файл")
    defer {
        print("закрываем файл")
    }

    print("читаем содержимое")
    return "ok"
}

print("--- 4A.13 defer ---")
let _ = try processFile()
// должно напечатать: открываем, читаем, закрываем

// несколько defer
func multi() {
    defer { print("3") }
    defer { print("2") }
    defer { print("1") }
    print("работаю")
}

print("--- multi defer ---")
multi()

// MARK: - 4A.14 throws + async

func fetchData() async throws -> String {
    return "async data"
}

print("--- 4A.14 try await ---")
let asyncGroup = DispatchGroup()
asyncGroup.enter()
Task {
    do {
        let d = try await fetchData()
        print("got:", d)
    } catch {
        print("error:", error)
    }
    asyncGroup.leave()
}
asyncGroup.wait()

// MARK: - Большое упражнение 4A.1/4A.2/4A.3

func parseTime(_ str: String) throws -> (hours: Int, minutes: Int) {
    guard !str.isEmpty else { throw TimeError.empty }
    let parts = str.split(separator: ":")
    guard parts.count == 2,
          let hours = Int(parts[0]),
          let minutes = Int(parts[1])
    else { throw TimeError.invalidFormat }

    guard (0...23).contains(hours) else { throw TimeError.invalidHours }
    guard (0...59).contains(minutes) else { throw TimeError.invalidMinutes }

    return (hours, minutes)
}

print("--- 4A.1/4A.2 parseTime ---")
for str in ["14:30", "00:00", "23:59", "", "abc", "25:00", "12:99"] {
    do {
        let (h, m) = try parseTime(str)
        print("\(str) → \(h):\(m)")
    } catch let e as TimeError {
        print("\(str) → \(e.localizedDescription)")
    } catch {
        print("\(str) → \(error)")
    }
}

// 4A.3 — все Result
func parseAllTimes(_ strings: [String]) -> [Result<(Int, Int), TimeError>] {
    return strings.map { str in
        do {
            let result = try parseTime(str)
            return .success(result)
        } catch let error as TimeError {
            return .failure(error)
        } catch {
            return .failure(.invalidFormat)
        }
    }
}

print("--- 4A.3 parseAllTimes ---")
let results = parseAllTimes(["14:30", "abc", "25:00"])
for r in results {
    switch r {
    case .success(let (h, m)):
        print("\(h):\(m)")
    case .failure(let error):
        print("Ошибка:", error.localizedDescription)
    }
}
