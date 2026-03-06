import Testing
import Foundation
@testable import app

@MainActor
struct LoginViewModelTests {
    @Test func appleLoginSuccessSetsAuthenticated() async {
        let apiClient = MockAPIClient()
        let session = SessionStore()
        let viewModel = LoginViewModel(
            authService: AuthService(apiClient: apiClient),
            session: session
        )

        let payload = AuthSuccessResponse(
            user: AuthUserPayload(id: "usr_1", email: "user@example.com", displayName: "User", authProvider: "apple"),
            isNewUser: false
        )
        apiClient.nextData = try! JSONEncoder().encode(payload)

        await viewModel.loginWithApple(identityToken: "header.payload.sig", authorizationCode: "code")

        #expect(session.isAuthenticated)
    }

    @Test func appleLoginFailureKeepsUnauthenticated() async {
        let apiClient = MockAPIClient()
        apiClient.nextError = NetworkError.requestFailed

        let session = SessionStore()
        let viewModel = LoginViewModel(
            authService: AuthService(apiClient: apiClient),
            session: session
        )

        await viewModel.loginWithApple(identityToken: "header.payload.sig", authorizationCode: "code")

        #expect(!session.isAuthenticated)
    }
}
