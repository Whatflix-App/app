import Foundation

final class ForYouService {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchRecommendations() async throws -> [Movie] {
        _ = try await apiClient.send(Endpoint.recommendations)
        return [Movie(id: UUID(), title: "For You - Basic Recs")]
    }
}
