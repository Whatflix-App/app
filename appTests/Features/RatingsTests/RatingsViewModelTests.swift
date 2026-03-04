import Testing
@testable import app

@MainActor
struct RatingsViewModelTests {
    @Test func hasRatingsTitle() {
        let viewModel = RatingsViewModel(service: RatingsService(apiClient: APIClient()))
        #expect(viewModel.title == "Ratings")
    }
}
