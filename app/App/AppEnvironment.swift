import Foundation

struct AppEnvironment {
    let apiClient: any APIClienting
    let authTokenStore: AuthTokenStore
    let localCache: LocalCache

    static let live = AppEnvironment.wiredLive

    init(apiClient: any APIClienting, authTokenStore: AuthTokenStore, localCache: LocalCache = LocalCache()) {
        self.apiClient = apiClient
        self.authTokenStore = authTokenStore
        self.localCache = localCache
    }

    static var wiredLive: AppEnvironment {
        let tokenStore = AuthTokenStore()
        return AppEnvironment(
            apiClient: APIClient(tokenStore: tokenStore),
            authTokenStore: tokenStore,
            localCache: LocalCache()
        )
    }

    func makeAuthService() -> AuthService {
        AuthService(apiClient: apiClient, tokenStore: authTokenStore)
    }

    func makeLoginViewModel(session: SessionStore) -> LoginViewModel {
        LoginViewModel(
            authService: makeAuthService(),
            session: session
        )
    }

    func makeOnboardingViewModel(session: SessionStore) -> OnboardingViewModel {
        OnboardingViewModel(
            service: OnboardingService(),
            session: session
        )
    }

    func makeForYouViewModel() -> ForYouViewModel {
        ForYouViewModel()
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(
            service: SearchService(apiClient: apiClient),
            cache: localCache
        )
    }

    func makeCatalogsViewModel() -> CatalogsViewModel {
        CatalogsViewModel(service: CatalogsService(apiClient: apiClient))
    }

    func makeCatalogState() -> CatalogState {
        CatalogState()
    }

    func makeCatalogsViewModel(catalogState: CatalogState) -> CatalogsViewModel {
        CatalogsViewModel(
            service: CatalogsService(apiClient: apiClient),
            catalogState: catalogState
        )
    }

    func makeWatchlistViewModel() -> WatchlistViewModel {
        WatchlistViewModel(service: WatchlistService(apiClient: apiClient))
    }

    func makeWatchlistState() -> WatchlistState {
        WatchlistState(service: WatchlistService(apiClient: apiClient))
    }

    func makeHistoryState() -> HistoryState {
        HistoryState(service: ProfileService(apiClient: apiClient))
    }

    func makeWatchlistViewModel(watchlistState: WatchlistState) -> WatchlistViewModel {
        WatchlistViewModel(
            service: WatchlistService(apiClient: apiClient),
            watchlistState: watchlistState
        )
    }

    func makeProfileViewModel(session: SessionStore, historyState: HistoryState) -> ProfileViewModel {
        ProfileViewModel(
            service: ProfileService(apiClient: apiClient),
            authService: makeAuthService(),
            session: session,
            historyState: historyState
        )
    }
}
