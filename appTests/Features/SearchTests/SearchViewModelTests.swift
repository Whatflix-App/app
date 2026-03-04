import Foundation
import Testing
@testable import app

@MainActor
struct SearchViewModelTests {
    @Test func runSearchPopulatesResults() async throws {
        let apiClient = MockAPIClient()
        let id = UUID()
        apiClient.nextData = try JSONEncoder().encode([
            ["id": id.uuidString, "title": "Arrival"]
        ])

        let viewModel = SearchViewModel(service: SearchService(apiClient: apiClient))
        viewModel.query = "Arrival"

        await viewModel.runSearch()

        #expect(viewModel.results.count == 1)
        #expect(viewModel.results.first?.title == "Arrival")
    }
}
