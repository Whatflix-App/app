import Foundation
import Testing
@testable import app

@MainActor
struct SearchViewModelTests {
    @Test func runSearchPopulatesResults() async throws {
        let apiClient = MockAPIClient()
        apiClient.nextData = """
        {
          "provider": "tmdb",
          "page": 1,
          "totalPages": 1,
          "totalResults": 1,
          "items": [
            {
              "movieId": "329",
              "title": "Jurassic Park",
              "overview": "Dinosaurs escape containment in a theme park.",
              "genreIds": [],
              "genres": ["Adventure", "Sci-Fi"],
              "backdropPath": null,
              "releaseDate": "1993-06-11",
              "voteAverage": 8.3,
              "voteCount": 100,
              "popularity": 99.0,
              "adult": false,
              "originalLanguage": "en"
            }
          ]
        }
        """.data(using: .utf8) ?? Data()

        let viewModel = SearchViewModel(
            service: SearchService(apiClient: apiClient),
            cache: LocalCache()
        )
        viewModel.query = "Jurassic Park"

        await viewModel.runSearch()

        #expect(viewModel.results.count == 1)
        #expect(viewModel.results.first?.title == "Jurassic Park")
        #expect(viewModel.cachedSearches.isEmpty)
    }

    @Test func recordSelectionCachesMovieAndDeduplicates() async throws {
        let apiClient = MockAPIClient()
        let cache = LocalCache()
        let cachedMovie = Movie(
            id: UUID(),
            title: "Alien",
            overview: "In space, no one can hear you scream.",
            genres: ["Sci-Fi"],
            movieId: "348"
        )
        cache.set(try JSONEncoder().encode([cachedMovie]), for: "search.recent.movies")

        apiClient.nextData = """
        {
          "provider": "tmdb",
          "page": 1,
          "totalPages": 1,
          "totalResults": 1,
          "items": [
            {
              "movieId": "348",
              "title": "Alien",
              "overview": "In space, no one can hear you scream.",
              "genreIds": [],
              "genres": ["Sci-Fi"],
              "backdropPath": null,
              "releaseDate": "1979-05-25",
              "voteAverage": 8.1,
              "voteCount": 100,
              "popularity": 99.0,
              "adult": false,
              "originalLanguage": "en"
            }
          ]
        }
        """.data(using: .utf8) ?? Data()

        let viewModel = SearchViewModel(
            service: SearchService(apiClient: apiClient),
            cache: cache
        )

        #expect(viewModel.cachedSearches.count == 1)
        #expect(viewModel.cachedSearches.first?.title == "Alien")

        let selectedMovie = Movie(
            id: UUID(),
            title: "Aliens",
            overview: "Ripley returns to LV-426.",
            genres: ["Sci-Fi"],
            movieId: "679"
        )
        viewModel.recordSelection(selectedMovie)

        #expect(viewModel.cachedSearches.count == 2)
        #expect(viewModel.cachedSearches.first?.movieId == "679")

        viewModel.recordSelection(cachedMovie)

        #expect(viewModel.cachedSearches.count == 2)
        #expect(viewModel.cachedSearches.first?.movieId == "348")
    }

    @Test func removeCachedSearchRemovesMovieFromHistory() async throws {
        let cache = LocalCache()
        let firstMovie = Movie(
            id: UUID(),
            title: "Alien",
            overview: "In space, no one can hear you scream.",
            genres: ["Sci-Fi"],
            movieId: "348"
        )
        let secondMovie = Movie(
            id: UUID(),
            title: "Aliens",
            overview: "Ripley returns to LV-426.",
            genres: ["Sci-Fi"],
            movieId: "679"
        )
        cache.set(try JSONEncoder().encode([firstMovie, secondMovie]), for: "search.recent.movies")

        let viewModel = SearchViewModel(
            service: SearchService(apiClient: MockAPIClient()),
            cache: cache
        )

        viewModel.removeCachedSearch(firstMovie)

        #expect(viewModel.cachedSearches.count == 1)
        #expect(viewModel.cachedSearches.first?.movieId == "679")
    }
}
