import Testing
import Foundation
@testable import app

@MainActor
struct LoginViewModelTests {
    @Test func appleLoginSuccessSetsAuthenticated() async {
        let apiClient = MockAPIClient()
        let session = SessionStore()
        let tokenStore = AuthTokenStore()
        let viewModel = LoginViewModel(
            authService: AuthService(apiClient: apiClient, tokenStore: tokenStore),
            session: session
        )

        let payload = AuthSuccessResponse(
            user: AuthUserPayload(id: "usr_1", email: "user@example.com", displayName: "User", authProvider: "apple"),
            tokens: AuthTokensPayload(
                accessToken: "token",
                accessTokenExpiresAt: Date(),
                refreshToken: "refresh",
                refreshTokenExpiresAt: Date().addingTimeInterval(3600)
            ),
            session: AuthSessionPayload(id: "sess_1", issuedAt: Date()),
            isNewUser: false
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        apiClient.nextData = try! encoder.encode(payload)

        await viewModel.loginWithApple(identityToken: "header.payload.sig", authorizationCode: "code")

        #expect(session.isAuthenticated)
    }

    @Test func appleLoginFailureKeepsUnauthenticated() async {
        let apiClient = MockAPIClient()
        apiClient.nextError = NetworkError.requestFailed

        let session = SessionStore()
        let tokenStore = AuthTokenStore()
        let viewModel = LoginViewModel(
            authService: AuthService(apiClient: apiClient, tokenStore: tokenStore),
            session: session
        )

        await viewModel.loginWithApple(identityToken: "header.payload.sig", authorizationCode: "code")

        #expect(!session.isAuthenticated)
    }
}
