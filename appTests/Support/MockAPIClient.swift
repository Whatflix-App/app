import Foundation
@testable import app

final class MockAPIClient: APIClienting {
    var nextData: Data = Data()
    var nextError: Error?

    func send(_ request: APIRequest) async throws -> Data {
        _ = request
        if let nextError {
            throw nextError
        }
        return nextData
    }
}
