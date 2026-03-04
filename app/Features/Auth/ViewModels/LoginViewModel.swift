import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var credentials = LoginCredentials()
    @Published var title = "Login"
    @Published var isLoading = false

    private let authService: any AuthServicing
    private let session: SessionStore

    init(authService: any AuthServicing, session: SessionStore) {
        self.authService = authService
        self.session = session
    }

    func login() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authService.login(with: credentials)
            session.isAuthenticated = true
        } catch {
            session.isAuthenticated = false
        }
    }
}
