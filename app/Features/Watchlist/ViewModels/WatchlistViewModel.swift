import Foundation
import Combine

@MainActor
final class WatchlistViewModel: ObservableObject {
    @Published var title = "Watchlist"
    @Published var errorMessage: String?
    @Published private(set) var items: [Movie] = []
    @Published private(set) var isLoading = false

    private let service: WatchlistService
    private let watchlistState: WatchlistState?

    init(service: WatchlistService, watchlistState: WatchlistState? = nil) {
        self.service = service
        self.watchlistState = watchlistState
    }

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        let loaded = (try? await service.fetchWatchlist()) ?? []
        items = loaded
        watchlistState?.sync(with: loaded)
    }

    func delete(movie: Movie) async {
        errorMessage = nil
        do {
            if let movieID = movie.movieId {
                try await service.deleteWatchlistItem(movieID: movieID)
                watchlistState?.markRemoved(movieID: movieID)
            } else {
                try await service.deleteWatchlistItem(movieID: movie.id)
            }
            items.removeAll { $0.id == movie.id }
        } catch {
            errorMessage = "Failed to remove \"\(movie.title)\". Please try again."
        }
    }

    func pruneItems(keeping movieIDs: Set<String>) {
        items.removeAll { movie in
            guard let movieID = movie.movieId else { return false }
            return !movieIDs.contains(movieID)
        }
    }
}
