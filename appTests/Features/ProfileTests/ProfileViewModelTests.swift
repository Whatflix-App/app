import Testing
@testable import app

@MainActor
struct ProfileViewModelTests {
    @Test func hasProfileTitle() {
        let viewModel = ProfileViewModel(
            service: ProfileService(apiClient: APIClient()),
            session: SessionStore()
        )
        #expect(viewModel.title == "Profile")
    }

    @Test func logoutClearsAuthentication() {
        let session = SessionStore()
        session.isAuthenticated = true
        let viewModel = ProfileViewModel(
            service: ProfileService(apiClient: APIClient()),
            session: session
        )

        viewModel.logout()

        #expect(!session.isAuthenticated)
    }
}
