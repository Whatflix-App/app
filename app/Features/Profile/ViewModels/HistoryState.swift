import Foundation
import Combine

@MainActor
final class HistoryState: ObservableObject {
    @Published private(set) var items: [WatchHistoryEntry] = []
    @Published private(set) var isRefreshing = false

    private let service: ProfileService
    private var hasLoadedOnce = false

    init(service: ProfileService) {
        self.service = service
    }

    func refresh(force: Bool = false) async {
        guard !isRefreshing else { return }
        if hasLoadedOnce && !force { return }

        isRefreshing = true
        defer { isRefreshing = false }

        guard let history = try? await service.fetchWatchHistory() else { return }
        sync(with: history)
    }

    func sync(with history: [WatchHistoryEntry]) {
        let sorted = history.sorted { lhs, rhs in
            if lhs.watchedAt != rhs.watchedAt {
                return lhs.watchedAt > rhs.watchedAt
            }
            return lhs.id > rhs.id
        }

        items = sorted
        hasLoadedOnce = true
    }

    func upsertRatingEntry(movie: Movie, movieID: String, watchedAt: Date = Date()) {
        let existingRatingEntry = items.first {
            $0.movieId == movieID && $0.source == "rating"
        }

        let entry = WatchHistoryEntry(
            id: existingRatingEntry?.id ?? "local_rating_\(movieID)",
            movieId: movieID,
            watchedAt: watchedAt,
            completed: true,
            progressPct: 100,
            source: "rating",
            movie: movie
        )

        items.removeAll { $0.movieId == movieID && $0.source == "rating" }
        items.append(entry)
        sync(with: items)
    }

    func removeRatingEntry(movieID: String) {
        items.removeAll { $0.movieId == movieID && $0.source == "rating" }
        hasLoadedOnce = true
    }
}
