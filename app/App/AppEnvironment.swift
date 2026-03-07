import Foundation

struct AppEnvironment {
    let apiClient: any APIClienting
    let authTokenStore: AuthTokenStore

    static let live = AppEnvironment.wiredLive

    init(apiClient: any APIClienting, authTokenStore: AuthTokenStore) {
        self.apiClient = apiClient
        self.authTokenStore = authTokenStore
    }

    static var wiredLive: AppEnvironment {
        let tokenStore = AuthTokenStore()
        return AppEnvironment(
            apiClient: APIClient(tokenStore: tokenStore),
            authTokenStore: tokenStore
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
        SearchViewModel(service: SearchService(apiClient: apiClient))
    }

    func makeCatalogsViewModel() -> CatalogsViewModel {
        CatalogsViewModel(service: CatalogsService(apiClient: apiClient))
    }

    func makeWatchlistViewModel() -> WatchlistViewModel {
        WatchlistViewModel(service: WatchlistService(apiClient: apiClient))
    }

    func makeProfileViewModel(session: SessionStore) -> ProfileViewModel {
        ProfileViewModel(
            service: ProfileService(apiClient: apiClient),
            authService: makeAuthService(),
            session: session
        )
    }
}
