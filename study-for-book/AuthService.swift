import Foundation

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

    var onLogout: (() -> Void)?

    var isLoggedIn: Bool { token != nil }

    func login(email: String, password: String) async throws -> LoginResponse {
        do {
            let result = try await APIClient.shared.login(email: email, password: password)
            store(result)
            return result
        } catch APIError.unauthorized {
            throw AuthError.invalidCredentials
        } catch {
            throw AuthError.network
        }
    }

    func register(name: String, email: String, password: String) async throws -> LoginResponse {
        let result = try await APIClient.shared.register(name: name, email: email, password: password)
        store(result)
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
        onLogout?()
    }

    private func store(_ result: LoginResponse) {
        token = result.token
        currentUser = result
        KeychainStorage.shared.save(result.token, for: "auth.token")
        UserDefaults.standard.set(result.userId, forKey: "auth.userId")
        UserDefaults.standard.set(result.name, forKey: "auth.name")
        UserDefaults.standard.set(result.email, forKey: "auth.email")
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
