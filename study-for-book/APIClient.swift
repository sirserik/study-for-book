import Foundation

enum HTTPMethod: String {
    case GET, POST, PUT, PATCH, DELETE
}

enum APIError: Error {
    case invalidURL
    case unauthorized
    case forbidden
    case notFound
    case server(Int)
    case decoding(Error)
    case network(Error)
}

struct LoginResponse: Codable {
    let token: String
    let userId: Int
    let name: String
    let email: String
}

@MainActor
final class APIClient {
    static let shared = APIClient()
    private init() {}

    private let baseURL = URL(string: "http://localhost:3000")!

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        // Сервер (Prisma) шлёт дату с миллисекундами: 2026-09-23T09:39:03.132Z.
        // Готовая стратегия .iso8601 на iOS такую строку не принимает.
        d.dateDecodingStrategy = .custom { decoder in
            let text = try decoder.singleValueContainer().decode(String.self)
            if let date = try? Date(text, strategy: Date.ISO8601FormatStyle(includingFractionalSeconds: true)) {
                return date
            }
            return try Date(text, strategy: .iso8601)
        }
        return d
    }()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    func request<T: Decodable>(
        _ path: String,
        method: HTTPMethod = .GET,
        body: Encodable? = nil,
        authenticated: Bool = true
    ) async throws -> T {

        guard let url = URL(string: path, relativeTo: baseURL) else {
            throw APIError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if authenticated, let token = AuthService.shared.token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        log(request)

        do {
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let http = response as? HTTPURLResponse else {
                throw APIError.network(URLError(.badServerResponse))
            }
            log(http, data: data)

            switch http.statusCode {
            case 200..<300: break
            case 401:
                AuthService.shared.logout()
                throw APIError.unauthorized
            case 403: throw APIError.forbidden
            case 404: throw APIError.notFound
            default:  throw APIError.server(http.statusCode)
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                throw APIError.decoding(error)
            }
        } catch let apiError as APIError {
            throw apiError
        } catch {
            throw APIError.network(error)
        }
    }

    private func log(_ request: URLRequest) {
        #if DEBUG
        print("→ \(request.httpMethod ?? "GET") \(request.url?.absoluteString ?? "")")
        if let body = request.httpBody, let str = String(data: body, encoding: .utf8) {
            print("   body: \(str)")
        }
        #endif
    }

    private func log(_ response: HTTPURLResponse, data: Data) {
        #if DEBUG
        print("← \(response.statusCode) \(response.url?.absoluteString ?? "")")
        if let str = String(data: data, encoding: .utf8) {
            print("   body: \(str.prefix(200))")
        }
        #endif
    }
}

private struct AnyEncodable: Encodable {
    let value: Encodable
    init(_ value: Encodable) { self.value = value }
    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

extension APIClient {
    func getProducts() async throws -> [Product] {
        try await request("/products", authenticated: false)
    }

    func getProduct(id: Int) async throws -> Product {
        try await request("/products/\(id)", authenticated: false)
    }

    func login(email: String, password: String) async throws -> LoginResponse {
        struct Body: Encodable { let email: String; let password: String }
        return try await request("/auth/login", method: .POST,
                                 body: Body(email: email, password: password),
                                 authenticated: false)
    }

    func register(name: String, email: String, password: String) async throws -> LoginResponse {
        struct Body: Encodable { let name: String; let email: String; let password: String }
        return try await request("/auth/register", method: .POST,
                                 body: Body(name: name, email: email, password: password),
                                 authenticated: false)
    }

    func placeOrder(items: [CartItem]) async throws -> Order {
        struct Body: Encodable {
            struct Item: Encodable { let productId: Int; let quantity: Int }
            let items: [Item]
        }
        let body = Body(items: items.map { .init(productId: $0.product.id, quantity: $0.quantity) })
        return try await request("/orders", method: .POST, body: body)
    }

    func getOrders() async throws -> [Order] {
        try await request("/orders")
    }
}
