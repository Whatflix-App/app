import Foundation

final class MovieDetailService {
    private let apiClient: any APIClienting

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    func fetchMovieDetail(id: UUID) async throws -> Movie {
        _ = (apiClient, id)
        return Movie(id: UUID(), title: "Movie Detail", overview: "Movie Overview")
    }
}
