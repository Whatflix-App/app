import Foundation
import Combine

@MainActor
final class WatchlistState: ObservableObject {
    @Published private(set) var movieIDs: Set<String> = []

    private let service: WatchlistService

    init(service: WatchlistService) {
        self.service = service
    }

    func refresh() async {
        guard let movies = try? await service.fetchWatchlist() else { return }
        sync(with: movies)
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
