import Foundation

enum Endpoint {
    static func appleLogin(_ payload: AppleLoginRequest) throws -> APIRequest {
        APIRequest(path: "auth/apple", method: "POST", body: try JSONEncoder().encode(payload))
    }

    static func refresh(_ payload: RefreshRequestPayload) throws -> APIRequest {
        APIRequest(path: "auth/refresh", method: "POST", body: try JSONEncoder().encode(payload))
    }

    static func logout(_ payload: LogoutRequestPayload) throws -> APIRequest {
        APIRequest(path: "auth/logout", method: "POST", body: try JSONEncoder().encode(payload))
    }

    static let health = APIRequest(path: "health", method: "GET")
    static let profile = APIRequest(path: "profile", method: "GET", requiresAuth: true)
    static let watchHistory = APIRequest(path: "history/watch", method: "GET", requiresAuth: true)
    static let catalogs = APIRequest(path: "catalogs", method: "GET", requiresAuth: true)
    static let watchlist = APIRequest(path: "watchlist", method: "GET", requiresAuth: true)

    static func searchMovies(
        query: String,
        page: Int = 1,
        includeAdult: Bool = false,
        language: String = "en-US"
    ) -> APIRequest {
        var components = URLComponents()
        components.path = "search/movies"
        components.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "includeAdult", value: includeAdult ? "true" : "false"),
            URLQueryItem(name: "language", value: language),
        ]
        let queryString = components.percentEncodedQuery ?? ""
        return APIRequest(path: "search/movies?\(queryString)", method: "GET", requiresAuth: true)
    }

    static func searchMovieByID(_ movieID: String, language: String = "en-US") -> APIRequest {
        var components = URLComponents()
        components.queryItems = [URLQueryItem(name: "language", value: language)]
        let queryString = components.percentEncodedQuery ?? ""
        return APIRequest(path: "search/movies/\(movieID)?\(queryString)", method: "GET", requiresAuth: true)
    }

    static func createCatalog(name: String, description: String?) throws -> APIRequest {
        struct Payload: Codable {
            let name: String
            let description: String?
        }

        return APIRequest(
            path: "catalogs",
            method: "POST",
            body: try JSONEncoder().encode(Payload(name: name, description: description)),
            requiresAuth: true
        )
    }

    static func deleteCatalog(id: String) -> APIRequest {
        APIRequest(path: "catalogs/\(id)", method: "DELETE", requiresAuth: true)
    }

    static func deleteWatchlistItem(movieID: String) -> APIRequest {
        APIRequest(path: "watchlist/\(movieID)", method: "DELETE", requiresAuth: true)
    }

    static func addWatchlistItem(movieID: String, notes: String? = nil, priority: Int? = nil) throws -> APIRequest {
        struct Payload: Codable {
            let movieId: String
            let notes: String?
            let priority: Int?
        }

        return APIRequest(
            path: "watchlist",
            method: "POST",
            body: try JSONEncoder().encode(Payload(movieId: movieID, notes: notes, priority: priority)),
            requiresAuth: true
        )
    }

    static func updateProfile(displayName: String?) throws -> APIRequest {
        struct Payload: Codable {
            let displayName: String?
        }
        return APIRequest(
            path: "profile",
            method: "PATCH",
            body: try JSONEncoder().encode(Payload(displayName: displayName)),
            requiresAuth: true
        )
    }

    static func movieUserState(movieID: String) -> APIRequest {
        APIRequest(path: "movies/\(movieID)/user-state", method: "GET", requiresAuth: true)
    }

    static func putMovieRating(movieID: String, rating: Int, source: String = "manual") throws -> APIRequest {
        struct Payload: Codable {
            let rating: Int
            let source: String
        }

        return APIRequest(
            path: "movies/\(movieID)/rating",
            method: "PUT",
            body: try JSONEncoder().encode(Payload(rating: rating, source: source)),
            requiresAuth: true
        )
    }

    static func deleteMovieRating(movieID: String) -> APIRequest {
        APIRequest(
            path: "movies/\(movieID)/rating",
            method: "DELETE",
            requiresAuth: true
        )
    }

}
