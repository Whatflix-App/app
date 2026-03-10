import Foundation
import Combine

@MainActor
final class WatchlistState: ObservableObject {
    @Published private(set) var movieIDs: Set<String> = []
    @Published private(set) var isRefreshing = false

    private let service: WatchlistService

    init(service: WatchlistService) {
        self.service = service
    }

    func refresh() async {
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }

        guard let ids = try? await service.fetchWatchlistIDs() else { return }
        if ids != movieIDs {
            movieIDs = ids
        }
    }

    func contains(movieID: String) -> Bool {
        movieIDs.contains(movieID)
    }

    func add(movieID: String) async throws {
        try await service.addWatchlistItem(movieID: movieID)
        movieIDs.insert(movieID)
    }

    func remove(movieID: String) async throws {
        try await service.deleteWatchlistItem(movieID: movieID)
        movieIDs.remove(movieID)
    }

    func markAdded(movieID: String) {
        movieIDs.insert(movieID)
    }

    func markRemoved(movieID: String) {
        movieIDs.remove(movieID)
    }

    func sync(with movies: [Movie]) {
        let updated = Set(movies.compactMap(\.movieId))
        if updated != movieIDs {
            movieIDs = updated
        }
    }
}
