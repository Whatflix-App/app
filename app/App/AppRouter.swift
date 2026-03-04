import SwiftUI

struct AppRouter: View {
    let environment: AppEnvironment
    @StateObject private var session = SessionStore()

    var body: some View {
        Group {
            if !session.isAuthenticated {
                LoginView(viewModel: LoginViewModel(authService: AuthService(apiClient: environment.apiClient)))
            } else if !session.hasCompletedOnboarding {
                OnboardingView(viewModel: OnboardingViewModel(service: OnboardingService()))
            } else {
                MainTabView(apiClient: environment.apiClient)
            }
        }
    }
}

private struct MainTabView: View {
    let apiClient: APIClient

    var body: some View {
        TabView {
            ForYouView(
                viewModel: ForYouViewModel(service: ForYouService(apiClient: apiClient)),
                searchViewModel: SearchViewModel(service: SearchService(apiClient: apiClient))
            )
            .tabItem { Label("For You", systemImage: "sparkles") }

            RatingsView(viewModel: RatingsViewModel(service: RatingsService(apiClient: apiClient)))
                .tabItem { Label("Ratings", systemImage: "star.leadinghalf.filled") }

            CatalogsView(viewModel: CatalogsViewModel(service: CatalogsService(apiClient: apiClient)))
                .tabItem { Label("Catalogs", systemImage: "books.vertical") }

            WatchlistView(viewModel: WatchlistViewModel(service: WatchlistService(apiClient: apiClient)))
                .tabItem { Label("Watchlist", systemImage: "bookmark") }

            ProfileView(viewModel: ProfileViewModel(service: ProfileService(apiClient: apiClient)))
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
