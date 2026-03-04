import Foundation

final class ProfileService {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchProfile() async throws -> User {
        _ = apiClient
        return User(id: UUID(), displayName: "Profile")
    }
}
