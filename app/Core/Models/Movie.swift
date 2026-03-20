import Foundation

struct Movie: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let overview: String
    let genres: [String]
    let addedAt: Date?
    let movieId: String?
    let backdropPath: String?
    let releaseDate: String?
    let runtimeMinutes: Int?
    let voteAverage: Double?
    let voteCount: Int?
    let popularity: Double?
    let adult: Bool?
    let originalLanguage: String?

    init(
        id: UUID,
        title: String,
        overview: String,
        genres: [String] = [],
        addedAt: Date? = nil,
        movieId: String? = nil,
        backdropPath: String? = nil,
        releaseDate: String? = nil,
        runtimeMinutes: Int? = nil,
        voteAverage: Double? = nil,
        voteCount: Int? = nil,
        popularity: Double? = nil,
        adult: Bool? = nil,
        originalLanguage: String? = nil
    ) {
        self.id = id
        self.title = title
        self.overview = overview
        self.genres = genres
        self.addedAt = addedAt
        self.movieId = movieId
        self.backdropPath = backdropPath
        self.releaseDate = releaseDate
        self.runtimeMinutes = runtimeMinutes
        self.voteAverage = voteAverage
        self.voteCount = voteCount
        self.popularity = popularity
        self.adult = adult
        self.originalLanguage = originalLanguage
    }
}
