import Foundation
@testable import app

final class MockAPIClient: APIClienting {
    var nextData: Data = Data()
    var nextError: Error?
    var queuedResults: [Result<Data, Error>] = []
    var responseHandler: ((APIRequest) throws -> Data)?
    private(set) var sentRequests: [APIRequest] = []

    func send(_ request: APIRequest) async throws -> Data {
        sentRequests.append(request)
        if let responseHandler {
            return try responseHandler(request)
        }
        if !queuedResults.isEmpty {
            let result = queuedResults.removeFirst()
            return try result.get()
        }
        if let nextError {
            throw nextError
        }
        return nextData
    }
}
