import Testing
@testable import app

@MainActor
struct LoginViewModelTests {
    @Test func loginSuccessSetsAuthenticated() async {
        let apiClient = MockAPIClient()
        let session = SessionStore()
        let viewModel = LoginViewModel(authService: AuthService(apiClient: apiClient), session: session)

        await viewModel.login()

        #expect(session.isAuthenticated)
    }

    @Test func loginFailureKeepsUnauthenticated() async {
        let apiClient = MockAPIClient()
        apiClient.nextError = NetworkError.requestFailed

        let session = SessionStore()
        let viewModel = LoginViewModel(authService: AuthService(apiClient: apiClient), session: session)

        await viewModel.login()

        #expect(!session.isAuthenticated)
    }
}
