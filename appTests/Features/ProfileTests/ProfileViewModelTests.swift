import Testing
@testable import app

@MainActor
struct ProfileViewModelTests {
    private struct MockAuthService: AuthServicing {
        func loginWithApple(identityToken: String, authorizationCode: String, fullName: String?) async throws -> AuthSuccessResponse {
            _ = (identityToken, authorizationCode, fullName)
            throw NetworkError.requestFailed
        }

        func refreshIfPossible() async throws -> RefreshResponsePayload {
            throw NetworkError.requestFailed
        }

        func logout() async {}

        func pingBackend() async throws {}
    }

    @Test func hasProfileTitle() {
        let historyState = HistoryState(
            service: ProfileService(apiClient: APIClient())
        )
        let viewModel = ProfileViewModel(
            service: ProfileService(apiClient: APIClient()),
            authService: MockAuthService(),
            session: SessionStore(),
            historyState: historyState
        )
        #expect(viewModel.title == "Profile")
    }

    @Test func logoutClearsAuthentication() async {
        let session = SessionStore()
        session.isAuthenticated = true
        let historyState = HistoryState(
            service: ProfileService(apiClient: APIClient())
        )
        let viewModel = ProfileViewModel(
            service: ProfileService(apiClient: APIClient()),
            authService: MockAuthService(),
            session: session,
            historyState: historyState
        )

        await viewModel.logout()

        #expect(!session.isAuthenticated)
    }

    @Test func loadFetchesWatchHistory() async {
        let apiClient = MockAPIClient()
        apiClient.responseHandler = { request in
            switch request.path {
            case "profile":
                return """
                {
                  "id": "user-1",
                  "email": "user@example.com",
                  "displayName": "Test User",
                  "fullName": "Test User"
                }
                """.data(using: .utf8) ?? Data()
            case "history/watch":
                return """
                {
                  "items": [
                    {
                      "id": "whe_1",
                      "userId": "user-1",
                      "movieId": "10138",
                      "watchedAt": "2026-03-16T00:00:00Z",
                      "completed": true,
                      "progressPct": 100,
                      "source": "manual",
                      "createdAt": "2026-03-16T00:00:00Z"
                    }
                  ],
                  "limit": 20,
                  "page": 1,
                  "nextCursor": null
                }
                """.data(using: .utf8) ?? Data()
            case "search/movies/10138?language=en-US":
                return """
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
            default:
                throw NetworkError.requestFailed
            }
        }

        let historyState = HistoryState(
            service: ProfileService(apiClient: apiClient)
        )
        let viewModel = ProfileViewModel(
            service: ProfileService(apiClient: apiClient),
            authService: MockAuthService(),
            session: SessionStore(),
            historyState: historyState
        )

        await viewModel.load()

        #expect(historyState.items.count == 1)
        #expect(historyState.items.first?.movieId == "10138")
        #expect(historyState.items.first?.movie?.title == "Iron Man 2")
        #expect(apiClient.sentRequests.count == 3)
        #expect(apiClient.sentRequests.contains(where: { $0.path == "history/watch" }))
        #expect(apiClient.sentRequests.contains(where: { $0.path == "search/movies/10138?language=en-US" }))
    }
}
