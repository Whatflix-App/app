import Foundation

enum Endpoint {
    static let login = APIRequest(path: "/login", method: "POST")
    static let recommendations = APIRequest(path: "/recommendations", method: "GET")
    static let search = APIRequest(path: "/search", method: "GET")
}
