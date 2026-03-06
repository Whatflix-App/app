import SwiftUI

struct AppRouter: View {
    let environment: AppEnvironment
    @StateObject private var session = SessionStore()

    var body: some View {
        Group {
            if !session.isAuthenticated {
                LoginView(viewModel: environment.makeLoginViewModel(session: session))
            } else if !session.hasCompletedOnboarding {
                OnboardingView(viewModel: environment.makeOnboardingViewModel(session: session))
            } else {
                MainTabView(environment: environment, session: session)
            }
        }
    }
}

private struct MainTabView: View {
    let environment: AppEnvironment
    let session: SessionStore

    @StateObject private var forYouViewModel: ForYouViewModel
    @StateObject private var searchViewModel: SearchViewModel
    @StateObject private var catalogsViewModel: CatalogsViewModel
    @StateObject private var watchlistViewModel: WatchlistViewModel
    @StateObject private var profileViewModel: ProfileViewModel

    init(environment: AppEnvironment, session: SessionStore) {
        self.environment = environment
        self.session = session
        _forYouViewModel = StateObject(wrappedValue: environment.makeForYouViewModel())
        _searchViewModel = StateObject(wrappedValue: environment.makeSearchViewModel())
        _catalogsViewModel = StateObject(wrappedValue: environment.makeCatalogsViewModel())
        _watchlistViewModel = StateObject(wrappedValue: environment.makeWatchlistViewModel())
        _profileViewModel = StateObject(wrappedValue: environment.makeProfileViewModel(session: session))
    }

    var body: some View {
        TabView {
            ForYouView(viewModel: forYouViewModel, searchViewModel: searchViewModel)
                .tabItem { Label("For You", systemImage: "sparkles") }

            CatalogsView(viewModel: catalogsViewModel)
                .tabItem { Label("Catalogs", systemImage: "books.vertical") }

            WatchlistView(viewModel: watchlistViewModel)
                .tabItem { Label("Watchlist", systemImage: "bookmark") }

            ProfileView(viewModel: profileViewModel)
                .tabItem { Label("Profile", systemImage: "person") }
        }
    }
}
