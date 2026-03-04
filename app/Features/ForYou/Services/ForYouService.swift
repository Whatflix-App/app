import Foundation

protocol ForYouServicing {
    func fetchRecommendations() async throws -> [Movie]
}

final class ForYouService: ForYouServicing {
    private struct RecommendationDTO: Decodable {
        let id: UUID
        let title: String
    }

    private let apiClient: any APIClienting

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    func fetchRecommendations() async throws -> [Movie] {
        let data = try await apiClient.send(Endpoint.recommendations)

        if data.isEmpty {
            return [Movie(id: UUID(), title: "For You - Basic Recs")]
        }

        let decoded = try JSONDecoder().decode([RecommendationDTO].self, from: data)
        return decoded.map { Movie(id: $0.id, title: $0.title) }
    }
}
