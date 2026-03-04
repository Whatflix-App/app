import Foundation

final class WatchlistService {
    private let apiClient: any APIClienting

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    func fetchWatchlist() async throws -> [Movie] {
        _ = apiClient
        return [Movie(id: UUID(), title: "Watchlist")]
    }
}
