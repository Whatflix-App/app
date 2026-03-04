import Foundation
import Testing
@testable import app

@MainActor
struct ForYouViewModelTests {
    @Test func loadPopulatesRecommendations() async throws {
        let apiClient = MockAPIClient()
        let id = UUID()
        apiClient.nextData = try JSONEncoder().encode([
            ["id": id.uuidString, "title": "Inception"]
        ])

        let viewModel = ForYouViewModel(service: ForYouService(apiClient: apiClient))

        await viewModel.load()

        #expect(viewModel.recommendations.count == 1)
        #expect(viewModel.recommendations.first?.title == "Inception")
    }
}
