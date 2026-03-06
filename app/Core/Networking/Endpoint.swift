import Foundation

enum Endpoint {
    static func appleLogin(_ payload: AppleLoginRequest) throws -> APIRequest {
        APIRequest(path: "auth/apple", method: "POST", body: try JSONEncoder().encode(payload))
    }

    static let health = APIRequest(path: "health", method: "GET")
    static let recommendations = APIRequest(path: "recommendations", method: "GET")
    static let search = APIRequest(path: "search", method: "GET")
}
