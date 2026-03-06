import Foundation

enum NetworkError: Error {
    case invalidURL
    case requestFailed
    case decodingFailed
    case unauthorized
    case serverError(code: String, message: String)
}
