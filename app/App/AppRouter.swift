import SwiftUI

struct AppRouter: View {
    let environment: AppEnvironment
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var session = SessionStore()
    @State private var isRestoringSession = false

    var body: some View {
        Group {
            if isRestoringSession {
                LoadingView()
            } else if !session.isAuthenticated && !AppFlags.disableAuthForOfflineTesting {
                LoginView(viewModel: environment.makeLoginViewModel(session: session))
            } else {
                MainTabView(environment: environment, session: session)
            }
        }
        .task {
            await restoreSessionIfNeeded()
        }
        .onChange(of: scenePhase) { _, newPhase in
            guard newPhase == .active else { return }
            Task {
                await refreshSessionOnForeground()
            }
        }
    }

    @MainActor
    private func restoreSessionIfNeeded() async {
        guard !AppFlags.disableAuthForOfflineTesting else { return }
        guard environment.authTokenStore.hasStoredSession else {
            session.markLoggedOut()
            return
        }

        isRestoringSession = true
        defer { isRestoringSession = false }

        do {
            _ = try await environment.makeAuthService().refreshIfPossible()
            session.markAuthenticated()
        } catch {
            environment.authTokenStore.clear()
            session.markLoggedOut()
        }
    }

    @MainActor
    private func refreshSessionOnForeground() async {
        guard !AppFlags.disableAuthForOfflineTesting else { return }
        guard !isRestoringSession else { return }
        guard environment.authTokenStore.hasStoredSession else { return }

        do {
            _ = try await environment.makeAuthService().refreshIfPossible()
            session.markAuthenticated()
        } catch {
            environment.authTokenStore.clear()
            session.markLoggedOut()
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
    @StateObject private var historyState: HistoryState
    @StateObject private var profileViewModel: ProfileViewModel

    init(environment: AppEnvironment, session: SessionStore) {
        self.environment = environment
        self.session = session
        let sharedCatalogState = environment.makeCatalogState()
        let sharedWatchlistState = environment.makeWatchlistState()
        let sharedHistoryState = environment.makeHistoryState()
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
        _historyState = StateObject(wrappedValue: sharedHistoryState)
        _profileViewModel = StateObject(
            wrappedValue: environment.makeProfileViewModel(session: session, historyState: sharedHistoryState)
        )
    }

    var body: some View {
        TabView {
//            ForYouView(viewModel: forYouViewModel, searchViewModel: searchViewModel)
//                .tabItem { Label("For You", systemImage: "sparkles") }

            WatchlistView(
                viewModel: watchlistViewModel,
                watchlistState: watchlistState,
                historyState: historyState
            )
                .tabItem { Label("Watchlist", systemImage: "bookmark") }

            SearchView(
                viewModel: searchViewModel,
                watchlistState: watchlistState,
                historyState: historyState
            )
                .tabItem { Label("Search", systemImage: "magnifyingglass") }
            
//            CatalogsView(viewModel: catalogsViewModel)
//                .tabItem { Label("Catalogs", systemImage: "books.vertical") }

           

            ProfileView(viewModel: profileViewModel, historyState: historyState)
                .tabItem { Label("Profile", systemImage: "person") }
        }
        .task {
            async let watchlistRefresh: Void = watchlistState.refresh()
            async let historyRefresh: Void = historyState.refresh()
            _ = await (watchlistRefresh, historyRefresh)
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
