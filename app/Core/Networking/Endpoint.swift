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
    static let catalogs = APIRequest(path: "catalogs", method: "GET", requiresAuth: true)

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

}
