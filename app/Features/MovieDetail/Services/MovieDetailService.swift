import Foundation

final class MovieDetailService {
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

    func fetchMovieDetail(id: UUID) async throws -> Movie {
        _ = (apiClient, id)
        return Movie(id: UUID(), title: "Movie Detail", overview: "Movie Overview")
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
}
