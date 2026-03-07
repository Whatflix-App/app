import Testing
@testable import app

@MainActor
struct ProfileViewModelTests {
    private struct MockAuthService: AuthServicing {
        func loginWithApple(identityToken: String, authorizationCode: String) async throws -> AuthSuccessResponse {
            _ = (identityToken, authorizationCode)
            throw NetworkError.requestFailed
        }

        func refreshIfPossible() async throws -> RefreshResponsePayload {
            throw NetworkError.requestFailed
        }

        func logout() async {}

        func pingBackend() async throws {}
    }

    @Test func hasProfileTitle() {
        let viewModel = ProfileViewModel(
            service: ProfileService(apiClient: APIClient()),
            authService: MockAuthService(),
            session: SessionStore()
        )
        #expect(viewModel.title == "Profile")
    }

    @Test func logoutClearsAuthentication() async {
        let session = SessionStore()
        session.isAuthenticated = true
        let viewModel = ProfileViewModel(
            service: ProfileService(apiClient: APIClient()),
            authService: MockAuthService(),
            session: session
        )

        await viewModel.logout()

        #expect(!session.isAuthenticated)
    }
}
