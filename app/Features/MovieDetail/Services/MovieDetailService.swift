import Foundation

final class MovieDetailService {
    private struct SearchMovieItemDTO: Decodable {
        let movieId: String
        let title: String
        let overview: String
        let genreIds: [Int]
        let genres: [String]
        let backdropPath: String?
        let releaseDate: String?
        let runtimeMinutes: Int?
        let voteAverage: Double
        let voteCount: Int
        let popularity: Double
        let adult: Bool
        let originalLanguage: String?
    }

    struct UserState: Decodable {
        struct Rating: Decodable {
            let value: Int
            let source: String
            let updatedAt: Date
        }

        let movieId: String
        let inWatchlist: Bool
        let rating: Rating?
    }

    struct RatingResponse: Decodable {
        struct Rating: Decodable {
            let value: Int
            let source: String
            let updatedAt: Date
        }

        let movieId: String
        let rating: Rating
    }

    struct RemoveRatingResponse: Decodable {
        let ok: Bool
    }

    private let apiClient: any APIClienting

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    func fetchMovieDetail(movieID: String) async throws -> Movie {
        let data = try await apiClient.send(Endpoint.searchMovieByID(movieID))

        do {
            let dto = try JSONDecoder().decode(SearchMovieItemDTO.self, from: data)
            return Movie(
                id: Self.uuidFromString(dto.movieId),
                title: dto.title,
                overview: dto.overview,
                genres: dto.genres,
                movieId: dto.movieId,
                backdropPath: dto.backdropPath,
                releaseDate: dto.releaseDate,
                runtimeMinutes: dto.runtimeMinutes,
                voteAverage: dto.voteAverage,
                voteCount: dto.voteCount,
                popularity: dto.popularity,
                adult: dto.adult,
                originalLanguage: dto.originalLanguage
            )
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    func fetchUserState(movieID: String) async throws -> UserState {
        let data = try await apiClient.send(Endpoint.movieUserState(movieID: movieID))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(UserState.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    func rateMovie(movieID: String, rating: Int, source: String = "manual") async throws -> RatingResponse {
        let data = try await apiClient.send(try Endpoint.putMovieRating(movieID: movieID, rating: rating, source: source))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            return try decoder.decode(RatingResponse.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    func clearMovieRating(movieID: String) async throws -> RemoveRatingResponse {
        let data = try await apiClient.send(Endpoint.deleteMovieRating(movieID: movieID))

        do {
            return try JSONDecoder().decode(RemoveRatingResponse.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
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
}
