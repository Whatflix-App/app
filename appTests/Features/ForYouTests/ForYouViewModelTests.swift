import Testing
@testable import app

@MainActor
struct ForYouViewModelTests {
    @Test func hasForYouTitle() {
        let viewModel = ForYouViewModel(service: ForYouService(apiClient: APIClient()))
        #expect(viewModel.title == "For You")
    }
}
