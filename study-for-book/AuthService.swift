import Foundation

struct LoginResponse: Codable {
    let token: String
    let userId: Int
    let name: String
    let email: String
}

enum AuthError: Error {
    case invalidCredentials
    case network
}

@MainActor
final class AuthService {
    static let shared = AuthService()
    private init() { restoreSession() }

    private(set) var token: String?
    private(set) var currentUser: LoginResponse?

    var isLoggedIn: Bool { token != nil }

    func login(email: String, password: String) async throws -> LoginResponse {
        struct Body: Encodable {
            let email: String
            let password: String
        }

        let url = URL(string: "http://localhost:3000/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(Body(email: email, password: password))

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw AuthError.network
        }
        if http.statusCode == 401 {
            throw AuthError.invalidCredentials
        }
        guard (200..<300).contains(http.statusCode) else {
            throw AuthError.network
        }

        let result = try JSONDecoder().decode(LoginResponse.self, from: data)

        token = result.token
        currentUser = result
        KeychainStorage.shared.save(result.token, for: "auth.token")
        UserDefaults.standard.set(result.userId, forKey: "auth.userId")
        UserDefaults.standard.set(result.name, forKey: "auth.name")
        UserDefaults.standard.set(result.email, forKey: "auth.email")

        return result
    }

    /// Обновить профиль после того, как сервер подтвердил изменение.
    func update(name: String, email: String) {
        guard let current = currentUser else { return }
        currentUser = LoginResponse(token: current.token, userId: current.userId,
                                    name: name, email: email)
        UserDefaults.standard.set(name, forKey: "auth.name")
        UserDefaults.standard.set(email, forKey: "auth.email")
    }

    func logout() {
        token = nil
        currentUser = nil
        KeychainStorage.shared.delete(for: "auth.token")
        UserDefaults.standard.removeObject(forKey: "auth.userId")
        UserDefaults.standard.removeObject(forKey: "auth.name")
        UserDefaults.standard.removeObject(forKey: "auth.email")
    }

    private func restoreSession() {
        guard let savedToken = KeychainStorage.shared.read(for: "auth.token") else { return }
        token = savedToken
        currentUser = LoginResponse(
            token: savedToken,
            userId: UserDefaults.standard.integer(forKey: "auth.userId"),
            name: UserDefaults.standard.string(forKey: "auth.name") ?? "",
            email: UserDefaults.standard.string(forKey: "auth.email") ?? ""
        )
    }
}
