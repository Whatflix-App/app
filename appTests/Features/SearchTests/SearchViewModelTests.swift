import Foundation
import Testing
@testable import app

@MainActor
struct SearchViewModelTests {
    @Test func runSearchPopulatesResults() async throws {
        let apiClient = MockAPIClient()
        apiClient.nextData = """
        {
          "provider": "tmdb",
          "page": 1,
          "totalPages": 1,
          "totalResults": 1,
          "items": [
            { "movieId": "329", "title": "Jurassic Park" }
          ]
        }
        """.data(using: .utf8) ?? Data()

        let viewModel = SearchViewModel(service: SearchService(apiClient: apiClient))
        viewModel.query = "Jurassic Park"

        await viewModel.runSearch()

        #expect(viewModel.results.count == 1)
        #expect(viewModel.results.first?.title == "Jurassic Park")
    }
}
