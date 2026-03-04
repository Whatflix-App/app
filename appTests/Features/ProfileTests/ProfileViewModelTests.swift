import Testing
@testable import app

@MainActor
struct ProfileViewModelTests {
    @Test func hasProfileTitle() {
        let viewModel = ProfileViewModel(service: ProfileService(apiClient: APIClient()))
        #expect(viewModel.title == "Profile")
    }
}
