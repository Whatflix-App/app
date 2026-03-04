import Foundation

final class AuthService {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func login(with credentials: LoginCredentials) async throws {
        _ = credentials
        _ = try await apiClient.send(Endpoint.login)
    }
}
