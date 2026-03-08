import Foundation

struct RecommendationImpressionsPayload: Codable {
    struct Impression: Codable {
        let movieId: String
        let position: Int
    }

    let requestId: String
    let surface: String
    let impressions: [Impression]
    let shownAt: Date?
}

struct RecommendationFeedbackPayload: Codable {
    let requestId: String
    let movieId: String
    let event: String
    let surface: String
    let position: Int?
    let timestamp: Date?
    let rating: Int?
    let scale: Int?
}

struct RateMoviePayload: Codable {
    let rating: Int
    let scale: Int
    let source: String
    let requestId: String?
}

struct MarkWatchedPayload: Codable {
    let completed: Bool
    let progressPct: Int?
    let watchedAt: Date?
    let source: String
}
