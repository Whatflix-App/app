import Testing
@testable import app

@MainActor
struct MovieDetailViewModelTests {
    @Test func hasMovieDetailTitles() {
        let viewModel = MovieDetailViewModel(service: MovieDetailService(apiClient: APIClient()))
        #expect(viewModel.fullScreenTitle == "Movie Card")
        #expect(viewModel.detailPopupTitle == "Movie Detail Card")
    }
}
