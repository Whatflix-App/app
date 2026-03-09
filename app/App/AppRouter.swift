import SwiftUI

struct AppRouter: View {
    let environment: AppEnvironment
    @StateObject private var session = SessionStore()

    var body: some View {
        Group {
            if !session.isAuthenticated && !AppFlags.disableAuthForOfflineTesting {
                LoginView(viewModel: environment.makeLoginViewModel(session: session))
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
    @State private var searchViewModel: SearchViewModel
    @StateObject private var catalogState: CatalogState
    @StateObject private var catalogsViewModel: CatalogsViewModel
    @StateObject private var watchlistState: WatchlistState
    @StateObject private var watchlistViewModel: WatchlistViewModel
    @StateObject private var profileViewModel: ProfileViewModel

    init(environment: AppEnvironment, session: SessionStore) {
        self.environment = environment
        self.session = session
        let sharedCatalogState = environment.makeCatalogState()
        let sharedWatchlistState = environment.makeWatchlistState()
        _forYouViewModel = StateObject(wrappedValue: environment.makeForYouViewModel())
        _searchViewModel = State(wrappedValue: environment.makeSearchViewModel())
        _catalogState = StateObject(wrappedValue: sharedCatalogState)
        _catalogsViewModel = StateObject(
            wrappedValue: environment.makeCatalogsViewModel(catalogState: sharedCatalogState)
        )
        _watchlistState = StateObject(wrappedValue: sharedWatchlistState)
        _watchlistViewModel = StateObject(
            wrappedValue: environment.makeWatchlistViewModel(watchlistState: sharedWatchlistState)
        )
        _profileViewModel = StateObject(wrappedValue: environment.makeProfileViewModel(session: session))
    }

    var body: some View {
        TabView {
//            ForYouView(viewModel: forYouViewModel, searchViewModel: searchViewModel)
//                .tabItem { Label("For You", systemImage: "sparkles") }

            WatchlistView(
                viewModel: watchlistViewModel,
                watchlistState: watchlistState
            )
                .tabItem { Label("Watchlist", systemImage: "bookmark") }

            SearchView(
                viewModel: searchViewModel,
                watchlistState: watchlistState
            )
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
            
//            CatalogsView(viewModel: catalogsViewModel)
//                .tabItem { Label("Catalogs", systemImage: "books.vertical") }

           

            ProfileView(viewModel: profileViewModel)
                .tabItem { Label("Profile", systemImage: "person") }
        }
        .task {
            await watchlistState.refresh()
        }
    }
}

#Preview("App Router") {
    AppRouter(environment: PreviewSupport.environment)
}

#Preview("Main Tabs") {
    MainTabView(
        environment: PreviewSupport.environment,
        session: PreviewSupport.session
    )
}
