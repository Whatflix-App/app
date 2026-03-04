import Testing
@testable import app

@MainActor
struct LoginViewModelTests {
    @Test func hasLoginTitle() {
        let viewModel = LoginViewModel(authService: AuthService(apiClient: APIClient()))
        #expect(viewModel.title == "Login")
    }
}
