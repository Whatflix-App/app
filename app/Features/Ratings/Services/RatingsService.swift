import Foundation

final class RatingsService {
    private let apiClient: any APIClienting

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    func fetchRatings() async throws -> [Rating] {
        _ = apiClient
        return [Rating(id: UUID(), movieTitle: "Ratings", score: 5)]
    }
}
