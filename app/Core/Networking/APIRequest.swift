import Foundation

struct APIRequest {
    let path: String
    let method: String
    let body: Data?
    let headers: [String: String]
    let requiresAuth: Bool

    init(
        path: String,
        method: String,
        body: Data? = nil,
        headers: [String: String] = [:],
        requiresAuth: Bool = false
    ) {
        self.path = path
        self.method = method
        self.body = body
        self.headers = headers
        self.requiresAuth = requiresAuth
    }
}
