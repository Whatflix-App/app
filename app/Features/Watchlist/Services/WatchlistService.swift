import Foundation

final class WatchlistService {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchWatchlist() async throws -> [Movie] {
        _ = apiClient
        return [Movie(id: UUID(), title: "Watchlist")]
    }
}
