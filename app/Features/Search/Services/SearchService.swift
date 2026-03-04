import Foundation

final class SearchService {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func search(query: String) async throws -> [Movie] {
        _ = query
        _ = try await apiClient.send(Endpoint.search)
        return [Movie(id: UUID(), title: "Movie Search")]
    }
}
