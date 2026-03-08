import SwiftUI

struct SearchOverlayView: View {
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var watchlistState: WatchlistState
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        ZStack {
            AppStyle.brandGradient
                .ignoresSafeArea()

            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                Text(viewModel.title)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(.white)

                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.white.opacity(0.85))

                    TextField("Search movies", text: $viewModel.query)
                        .textFieldStyle(.plain)
                        .foregroundStyle(.white)
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
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .glassEffect(in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        if viewModel.results.isEmpty {
                            Text(viewModel.query.isEmpty ? "Type to search" : "No results")
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 8)
                        } else {
                            ForEach(viewModel.results) { movie in
                                MovieCardMiniView(
                                    movie: movie,
                                    watchlistState: watchlistState,
                                    title: movie.title,
                                    dateWatched: nil,
                                    overview: movie.overview,
                                    imageName: nil,
                                    prefix: "Matched"
                                )
                            }
                        }
                    }
                }
            }
            .padding(20)
        }
        .toolbarBackground(.hidden, for: .navigationBar)
        .task {
            // A delay ensures the navigation transition completes before bringing up the keyboard,
            // avoiding animation stutter.
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            isSearchFieldFocused = true
        }
    }
}

#Preview {
    SearchOverlayView(
        viewModel: PreviewSupport.searchViewModel,
        watchlistState: PreviewSupport.watchlistState
    )
}
