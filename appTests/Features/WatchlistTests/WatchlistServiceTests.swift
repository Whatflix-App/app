import Foundation
import Testing
@testable import app

struct WatchlistServiceTests {
    @Test func fetchWatchlistSkipsItemsWhenMovieLookupFails() async throws {
        let apiClient = MockAPIClient()
        apiClient.queuedResults = [
            .success(
                """
                [
                  {
                    "userId": "user-1",
                    "movieId": "1726",
                    "addedAt": "2026-03-08T00:00:00Z",
                    "notes": null,
                    "priority": null
                  },
                  {
                    "userId": "user-1",
                    "movieId": "10138",
                    "addedAt": "2026-03-08T00:00:00Z",
                    "notes": "Keep this one",
                    "priority": null
                  }
                ]
                """.data(using: .utf8) ?? Data()
            ),
            .failure(NetworkError.requestFailed),
            .success(
                """
                {
                  "movieId": "10138",
                  "title": "Iron Man 2",
                  "overview": "Tony Stark faces new threats.",
                  "genreIds": [28, 12],
                  "genres": ["Action", "Adventure"],
                  "backdropPath": "/poster.jpg",
                  "releaseDate": "2010-05-07",
                  "voteAverage": 6.8,
                  "voteCount": 21000,
                  "popularity": 55.0,
                  "adult": false,
                  "originalLanguage": "en"
                }
                """.data(using: .utf8) ?? Data()
            ),
        ]

        let service = WatchlistService(apiClient: apiClient)
        let movies = try await service.fetchWatchlist()

        #expect(movies.count == 1)
        #expect(movies[0].movieId == "10138")
        #expect(movies[0].title == "Iron Man 2")
        #expect(movies[0].addedAt == ISO8601DateFormatter().date(from: "2026-03-08T00:00:00Z"))

        #expect(apiClient.sentRequests.count == 3)
        #expect(apiClient.sentRequests[0].path == "watchlist")
        #expect(apiClient.sentRequests[1].path == "search/movies/1726?language=en-US")
        #expect(apiClient.sentRequests[2].path == "search/movies/10138?language=en-US")
    }
}
