import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    @Published var title = "Profile"
    @Published var displayName = "Loading..."
    @Published var fullName = ""
    @Published var email = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: ProfileService
    private let authService: any AuthServicing
    private let session: SessionStore

    init(service: ProfileService, authService: any AuthServicing, session: SessionStore) {
        self.service = service
        self.authService = authService
        self.session = session
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let user = try await service.fetchProfile()
            displayName = user.displayName ?? "User"
            fullName = user.fullName ?? ""
            email = user.email ?? ""
        } catch {
            errorMessage = "Failed to load profile"
        }
    }

    func logout() async {
        await authService.logout()
        session.markLoggedOut()
    }
}
