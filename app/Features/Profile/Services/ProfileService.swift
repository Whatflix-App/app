import Foundation

final class ProfileService {
    private let apiClient: any APIClienting

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    func fetchProfile() async throws -> User {
        _ = apiClient
        return User(id: UUID(), displayName: "Profile")
    }
}
