import Foundation
import Testing
@testable import app

struct SearchServiceTests {
    @Test func searchUsesBackendSearchRouteAndDecodesItems() async throws {
        let apiClient = MockAPIClient()
        apiClient.nextData = """
        {
          "provider": "tmdb",
          "page": 1,
          "totalPages": 1,
          "totalResults": 2,
          "items": [
            { "movieId": "1726", "title": "Iron Man" },
            { "movieId": "10138", "title": "Iron Man 2" }
          ]
        }
        """.data(using: .utf8) ?? Data()

        let service = SearchService(apiClient: apiClient)
        let movies = try await service.search(query: "iron man")

        #expect(movies.count == 2)
        #expect(movies.first?.title == "Iron Man")

        let request = try #require(apiClient.sentRequests.first)
        #expect(request.path == "search/movies?q=iron%20man&page=1&includeAdult=false&language=en-US")
        #expect(request.method == "GET")
        #expect(request.requiresAuth)
    }

    @Test func searchReturnsEmptyWhenQueryBlank() async throws {
        let apiClient = MockAPIClient()
        let service = SearchService(apiClient: apiClient)

        let movies = try await service.search(query: "   ")

        #expect(movies.isEmpty)
        #expect(apiClient.sentRequests.isEmpty)
    }
}
