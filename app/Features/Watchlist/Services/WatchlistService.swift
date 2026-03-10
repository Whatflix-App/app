import Foundation

final class WatchlistService {
    private struct WatchlistItemDTO: Decodable {
        let userId: String
        let movieId: String
        let addedAt: Date
        let notes: String?
        let priority: Int?
    }

    private struct SearchMovieItemDTO: Decodable {
        let movieId: String
        let title: String
        let overview: String
        let genreIds: [Int]
        let genres: [String]
        let backdropPath: String?
        let releaseDate: String?
        let voteAverage: Double
        let voteCount: Int
        let popularity: Double
        let adult: Bool
        let originalLanguage: String?
    }

    private let apiClient: any APIClienting

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    func fetchWatchlist() async throws -> [Movie] {
        let decoded = try await fetchWatchlistItems()

        var movies: [Movie] = []
        movies.reserveCapacity(decoded.count)
        for item in decoded {
            do {
                let movie = try await Self.enrichedMovie(item: item, apiClient: apiClient)
                movies.append(movie)
            } catch {
                continue
            }
        }
        return movies
    }

    func fetchWatchlistIDs() async throws -> Set<String> {
        let decoded = try await fetchWatchlistItems()
        return Set(decoded.map(\.movieId))
    }

    func deleteWatchlistItem(movieID: UUID) async throws {
        try await deleteWatchlistItem(movieID: movieID.uuidString)
    }

    func deleteWatchlistItem(movieID: String) async throws {
        _ = try await apiClient.send(Endpoint.deleteWatchlistItem(movieID: movieID))
    }

    func addWatchlistItem(movieID: String) async throws {
        _ = try await apiClient.send(try Endpoint.addWatchlistItem(movieID: movieID))
    }

    private static func uuidFromString(_ value: String) -> UUID {
        if let parsed = UUID(uuidString: value) {
            return parsed
        }

        let hash = value.utf8.reduce(into: UInt64(1469598103934665603)) { result, byte in
            result ^= UInt64(byte)
            result &*= 1099511628211
        }
        let hex = String(format: "%016llx%016llx", hash, hash ^ 0x9e3779b97f4a7c15)
        let segment1 = String(hex.prefix(8))
        let segment2 = String(hex.dropFirst(8).prefix(4))
        let segment3 = String(hex.dropFirst(12).prefix(4))
        let segment4 = String(hex.dropFirst(16).prefix(4))
        let segment5 = String(hex.dropFirst(20).prefix(12))
        let uuidString = "\(segment1)-\(segment2)-\(segment3)-\(segment4)-\(segment5)"
        return UUID(uuidString: uuidString) ?? UUID()
    }

    private static func enrichedMovie(item: WatchlistItemDTO, apiClient: any APIClienting) async throws -> Movie {
        let data = try await apiClient.send(Endpoint.searchMovieByID(item.movieId))
        let dto = try JSONDecoder().decode(SearchMovieItemDTO.self, from: data)
        return Movie(
            id: uuidFromString(item.movieId),
            title: dto.title,
            overview: dto.overview.isEmpty ? (item.notes ?? "Saved to watchlist") : dto.overview,
            genres: dto.genres,
            movieId: dto.movieId,
            backdropPath: dto.backdropPath,
            releaseDate: dto.releaseDate,
            voteAverage: dto.voteAverage,
            voteCount: dto.voteCount,
            popularity: dto.popularity,
            adult: dto.adult,
            originalLanguage: dto.originalLanguage
        )
    }

    private func fetchWatchlistItems() async throws -> [WatchlistItemDTO] {
        let data = try await apiClient.send(Endpoint.watchlist)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([WatchlistItemDTO].self, from: data)
    }
}
