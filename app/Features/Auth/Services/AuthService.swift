import Foundation

protocol AuthServicing {
    func login(with credentials: LoginCredentials) async throws
}

final class AuthService: AuthServicing {
    private let apiClient: any APIClienting

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    func login(with credentials: LoginCredentials) async throws {
        _ = credentials
        _ = try await apiClient.send(Endpoint.login)
    }
}
