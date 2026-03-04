import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var credentials = LoginCredentials()
    @Published var title = "Login"

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    func login() async {
        try? await authService.login(with: credentials)
    }
}
