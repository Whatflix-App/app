import Foundation

@MainActor
enum PreviewSupport {
    static let session: SessionStore = {
        let session = SessionStore()
        session.markAuthenticated()
        session.hasCompletedOnboarding = true
        return session
    }()

    static let unauthenticatedSession = SessionStore()

    static let apiClient: any APIClienting = PreviewAPIClient()
    static let authTokenStore = AuthTokenStore()
    static let localCache = LocalCache()

    static let environment = AppEnvironment(
        apiClient: apiClient,
        authTokenStore: authTokenStore,
        localCache: localCache
    )

    static let loginViewModel = LoginViewModel(
        authService: PreviewAuthService(),
        session: unauthenticatedSession
    )

    static let onboardingViewModel = OnboardingViewModel(
        service: OnboardingService(),
        session: unauthenticatedSession
    )

    static let forYouViewModel = ForYouViewModel()

    static let searchViewModel = SearchViewModel(
        service: SearchService(apiClient: apiClient),
        cache: localCache
    )

    static let catalogState = CatalogState()

    static let catalogsViewModel = CatalogsViewModel(
        service: CatalogsService(apiClient: apiClient),
        catalogState: catalogState
    )

    static let watchlistState = WatchlistState(
        service: WatchlistService(apiClient: apiClient)
    )

    static let watchlistViewModel = WatchlistViewModel(
        service: WatchlistService(apiClient: apiClient),
        watchlistState: watchlistState
    )

    static let historyState = HistoryState(
        service: ProfileService(apiClient: apiClient)
    )

    static let profileViewModel = ProfileViewModel(
        service: ProfileService(apiClient: apiClient),
        authService: PreviewAuthService(),
        session: session,
        historyState: historyState
    )

    static let movieDetailViewModel = MovieDetailViewModel(
        service: MovieDetailService(apiClient: apiClient)
    )
}

private struct PreviewAPIClient: APIClienting {
    func send(_ request: APIRequest) async throws -> Data {
        _ = request
        return Data()
    }
}

private struct PreviewAuthService: AuthServicing {
    func loginWithApple(identityToken: String, authorizationCode: String, fullName: String?) async throws -> AuthSuccessResponse {
        _ = (identityToken, authorizationCode, fullName)
        return AuthSuccessResponse(
            user: AuthUserPayload(
                id: UUID().uuidString,
                email: "preview@whatflix.app",
                displayName: "Preview User",
                authProvider: "apple"
            ),
            tokens: AuthTokensPayload(
                accessToken: "preview-access-token",
                accessTokenExpiresAt: Date().addingTimeInterval(3600),
                refreshToken: "preview-refresh-token",
                refreshTokenExpiresAt: Date().addingTimeInterval(30 * 24 * 3600)
            ),
            session: AuthSessionPayload(
                id: UUID().uuidString,
                issuedAt: Date()
            ),
            isNewUser: false
        )
    }

    func refreshIfPossible() async throws -> RefreshResponsePayload {
        RefreshResponsePayload(
            tokens: AuthTokensPayload(
                accessToken: "preview-access-token",
                accessTokenExpiresAt: Date().addingTimeInterval(3600),
                refreshToken: "preview-refresh-token",
                refreshTokenExpiresAt: Date().addingTimeInterval(30 * 24 * 3600)
            )
        )
    }

    func logout() async {}

    func pingBackend() async throws {}
}
