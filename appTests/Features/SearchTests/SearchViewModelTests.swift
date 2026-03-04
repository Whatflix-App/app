import Testing
@testable import app

@MainActor
struct SearchViewModelTests {
    @Test func hasSearchTitle() {
        let viewModel = SearchViewModel(service: SearchService(apiClient: APIClient()))
        #expect(viewModel.title == "Movie Search")
    }
}
