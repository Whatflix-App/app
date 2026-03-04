import Foundation

struct AppEnvironment {
    let apiClient: any APIClienting
    let authTokenStore: AuthTokenStore

    static let live = AppEnvironment(
        apiClient: APIClient(),
        authTokenStore: AuthTokenStore()
    )

    func makeLoginViewModel(session: SessionStore) -> LoginViewModel {
        LoginViewModel(
            authService: AuthService(apiClient: apiClient),
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
        ForYouViewModel(service: ForYouService(apiClient: apiClient))
    }

    func makeSearchViewModel() -> SearchViewModel {
        SearchViewModel(service: SearchService(apiClient: apiClient))
    }

    func makeRatingsViewModel() -> RatingsViewModel {
        RatingsViewModel(service: RatingsService(apiClient: apiClient))
    }

    func makeCatalogsViewModel() -> CatalogsViewModel {
        CatalogsViewModel(service: CatalogsService(apiClient: apiClient))
    }

    func makeWatchlistViewModel() -> WatchlistViewModel {
        WatchlistViewModel(service: WatchlistService(apiClient: apiClient))
    }

    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(service: ProfileService(apiClient: apiClient))
    }
}
