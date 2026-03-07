import Foundation

final class WatchlistService {
    private let apiClient: any APIClienting

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    func fetchWatchlist() async throws -> [Movie] {
        _ = apiClient
        return [
            Movie(id: UUID(), title: "Afterglow District"),
            Movie(id: UUID(), title: "Night Protocol"),
            Movie(id: UUID(), title: "Silent Current"),
            Movie(id: UUID(), title: "Echo of Winter"),
            Movie(id: UUID(), title: "Parallel Tide"),
        ]
    }

    func deleteWatchlistItem(movieID: UUID) async throws {
        _ = try await apiClient.send(Endpoint.deleteWatchlistItem(movieID: movieID.uuidString))
    }
}
