import Foundation

final class MovieDetailService {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchMovieDetail(id: UUID) async throws -> Movie {
        _ = (apiClient, id)
        return Movie(id: UUID(), title: "Movie Detail")
    }
}
