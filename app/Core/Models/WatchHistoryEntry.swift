import Foundation

struct WatchHistoryEntry: Identifiable, Codable, Hashable {
    let id: String
    let movieId: String
    let watchedAt: Date
    let completed: Bool
    let progressPct: Int
    let source: String
    let movie: Movie?
}
