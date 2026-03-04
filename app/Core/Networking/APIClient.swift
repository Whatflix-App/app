import Foundation

protocol APIClienting {
    func send(_ request: APIRequest) async throws -> Data
}

final class APIClient: APIClienting {
    func send(_ request: APIRequest) async throws -> Data {
        _ = request
        return Data()
    }
}
