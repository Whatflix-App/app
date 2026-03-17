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
    private var hasLoadedOnce = false

    init(service: WatchlistService, watchlistState: WatchlistState? = nil) {
        self.service = service
        self.watchlistState = watchlistState
    }

    func load(force: Bool = false) async {
        guard !isLoading else { return }
        if hasLoadedOnce && !force { return }

        isLoading = true
        defer { isLoading = false }

        let loaded = (try? await service.fetchWatchlist()) ?? []
        items = loaded
        hasLoadedOnce = true
        watchlistState?.sync(with: loaded)
    }

    func delete(movie: Movie) async {
        errorMessage = nil
        do {
            if let movieID = movie.movieId {
                if let watchlistState {
                    try await watchlistState.remove(movieID: movieID)
                } else {
                    try await service.deleteWatchlistItem(movieID: movieID)
                }
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

    func reconcile(with movieIDs: Set<String>) async {
        let loadedIDs = Set(items.compactMap(\.movieId))
        let addedIDs = movieIDs.subtracting(loadedIDs)
        if !addedIDs.isEmpty {
            await load(force: true)
            return
        }

        pruneItems(keeping: movieIDs)
    }
}
