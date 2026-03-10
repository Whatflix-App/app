import SwiftUI

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var watchlistState: WatchlistState
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        ZStack {
            AppStyle.screenBackground()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(FlicksColors.primaryText.opacity(0.7))

                    TextField("Search movies", text: $viewModel.query)
                        .textFieldStyle(.plain)
                        .foregroundStyle(FlicksColors.primaryText)
                        .focused($isSearchFieldFocused)
                        .submitLabel(.search)
                        .onSubmit {
                            Task { await viewModel.runSearch() }
                        }
                        .onChange(of: viewModel.query) { _, _ in
                            viewModel.scheduleSearch()
                        }

                    if !viewModel.query.isEmpty {
                        Button {
                            viewModel.query = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(FlicksColors.primaryText.opacity(0.6))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .glassEffect(in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if displayMovies.isEmpty {
                            Text(viewModel.query.isEmpty ? "Type to search" : "No results")
                                .font(.headline)
                                .foregroundStyle(FlicksColors.primaryText.opacity(0.75))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                        } else {
                            if viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("Recent Searches")
                                    .font(.headline)
                                    .foregroundStyle(FlicksColors.primaryText.opacity(0.8))
                                    .padding(.top, 8)
                            }

                            ForEach(displayMovies) { movie in
                                MovieCardMiniView(
                                    movie: movie,
                                    watchlistState: watchlistState,
                                    title: movie.title,
                                    dateWatched: nil,
                                    overview: movie.overview,
                                    imageName: nil,
                                    prefix: "Matched",
                                    onTap: {
                                        viewModel.recordSelection(movie)
                                    }
                                )
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .toolbarBackground(FlicksColors.background, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .task {
            // A delay ensures the navigation transition completes before bringing up the keyboard,
            // avoiding animation stutter.
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            isSearchFieldFocused = true
        }
    }

    private var displayMovies: [Movie] {
        let trimmedQuery = viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedQuery.isEmpty ? viewModel.cachedSearches : viewModel.results
    }
}

#Preview {
    SearchView(
        viewModel: PreviewSupport.searchViewModel,
        watchlistState: PreviewSupport.watchlistState
    )
}
