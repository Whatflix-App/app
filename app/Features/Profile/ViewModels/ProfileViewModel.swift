import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var title = "Profile"

    private let service: ProfileService
    private let session: SessionStore

    init(service: ProfileService, session: SessionStore) {
        self.service = service
        self.session = session
    }

    func load() async {
        _ = try? await service.fetchProfile()
    }

    func logout() {
        session.isAuthenticated = false
    }
}
