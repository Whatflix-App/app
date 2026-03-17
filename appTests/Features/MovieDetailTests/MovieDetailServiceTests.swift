import Foundation
import Testing
@testable import app

struct MovieDetailServiceTests {
    @Test func fetchUserStateUsesCombinedRouteAndDecodesResponse() async throws {
        let apiClient = MockAPIClient()
        apiClient.nextData = """
        {
          "movieId": "603",
          "inWatchlist": true,
          "rating": {
            "value": 1,
            "source": "manual",
            "updatedAt": "2026-03-16T15:12:00Z"
          }
        }
        """.data(using: .utf8) ?? Data()

        let service = MovieDetailService(apiClient: apiClient)
        let userState = try await service.fetchUserState(movieID: "603")

        #expect(userState.movieId == "603")
        #expect(userState.inWatchlist)
        #expect(userState.rating?.value == 1)

        let request = try #require(apiClient.sentRequests.first)
        #expect(request.path == "movies/603/user-state")
        #expect(request.method == "GET")
        #expect(request.requiresAuth)
    }

    @Test func rateMovieUsesRatingsRouteAndDecodesResponse() async throws {
        let apiClient = MockAPIClient()
        apiClient.nextData = """
        {
          "movieId": "603",
          "rating": {
            "value": -1,
            "source": "manual",
            "updatedAt": "2026-03-16T15:12:00Z"
          }
        }
        """.data(using: .utf8) ?? Data()

        let service = MovieDetailService(apiClient: apiClient)
        let response = try await service.rateMovie(movieID: "603", rating: -1)

        #expect(response.movieId == "603")
        #expect(response.rating.value == -1)

        let request = try #require(apiClient.sentRequests.first)
        #expect(request.path == "movies/603/rating")
        #expect(request.method == "PUT")
        #expect(request.requiresAuth)
    }

    @Test func clearMovieRatingUsesDeleteRouteAndDecodesResponse() async throws {
        let apiClient = MockAPIClient()
        apiClient.nextData = """
        {
          "ok": true
        }
        """.data(using: .utf8) ?? Data()

        let service = MovieDetailService(apiClient: apiClient)
        let response = try await service.clearMovieRating(movieID: "603")

        #expect(response.ok)

        let request = try #require(apiClient.sentRequests.first)
        #expect(request.path == "movies/603/rating")
        #expect(request.method == "DELETE")
        #expect(request.requiresAuth)
    }
}
