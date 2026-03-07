import Foundation
import Combine

@MainActor
final class WatchlistViewModel: ObservableObject {
    @Published var title = "Watchlist"
    @Published private(set) var items: [Movie] = []

    private let service: WatchlistService

    init(service: WatchlistService) {
        self.service = service
    }

    func load() async {
        items = (try? await service.fetchWatchlist()) ?? []
    }

    func delete(movie: Movie) async {
        do {
            try await service.deleteWatchlistItem(movieID: movie.id)
            items.removeAll { $0.id == movie.id }
        } catch {
        }
    }
}
