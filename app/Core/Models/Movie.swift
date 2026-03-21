import Foundation

struct Movie: Identifiable, Hashable, Codable {
    struct Person: Hashable, Codable, Identifiable {
        let id: String
        let name: String
        let role: String?
        let profilePath: String?
        let order: Int?
    }

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
    let director: String?
    let cast: [Person]

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
        originalLanguage: String? = nil,
        director: String? = nil,
        cast: [Person] = []
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
        self.director = director
        self.cast = cast
    }
}
