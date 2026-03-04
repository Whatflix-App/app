import Testing
@testable import app

@MainActor
struct WatchlistViewModelTests {
    @Test func hasWatchlistTitle() {
        let viewModel = WatchlistViewModel(service: WatchlistService(apiClient: APIClient()))
        #expect(viewModel.title == "Watchlist")
    }
}
