import Foundation

struct AppEnvironment {
    let apiClient: any APIClienting

    static let live = AppEnvironment.wiredLive

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    static var wiredLive: AppEnvironment {
        AppEnvironment(apiClient: APIClient())
    }

    func makeAuthService() -> AuthService {
        AuthService(apiClient: apiClient)
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
        ForYouViewModel(service: ForYouService(apiClient: apiClient))
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
            session: session
        )
    }
}
