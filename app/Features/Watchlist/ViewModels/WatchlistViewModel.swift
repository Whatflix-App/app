import Foundation
import Combine

@MainActor
final class WatchlistViewModel: ObservableObject {
    @Published var title = "Watchlist"

    private let service: WatchlistService

    init(service: WatchlistService) {
        self.service = service
    }

    func load() async {
        _ = try? await service.fetchWatchlist()
    }
}
