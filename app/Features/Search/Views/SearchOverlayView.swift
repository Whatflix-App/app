import SwiftUI
import UIKit

struct SearchView: View {
    @ObservedObject var viewModel: SearchViewModel
    @ObservedObject var watchlistState: WatchlistState
    @FocusState private var isSearchFieldFocused: Bool

    var body: some View {
        ZStack {
            SystemScreenBackground()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(SystemTheme.secondaryText)

                    TextField("Search movies", text: $viewModel.query)
                        .textFieldStyle(.plain)
                        .foregroundStyle(SystemTheme.primaryText)
                        .focused($isSearchFieldFocused)
                        .autocorrectionDisabled(true)
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
                                .foregroundStyle(SystemTheme.secondaryText)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .glassEffect(in: RoundedRectangle(cornerRadius: 22, style: .continuous))

                List {
                    if displayMovies.isEmpty {
                        Text(viewModel.query.isEmpty ? "Type to search" : "No results")
                            .font(.headline)
                            .foregroundStyle(SystemTheme.secondaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    } else {
                        if viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text("Recent Searches")
                                .font(.headline)
                                .foregroundStyle(SystemTheme.secondaryText)
                                .padding(.top, 8)
                                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 4, trailing: 0))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }

                        ForEach(displayMovies) { movie in
                            recentSearchRow(for: movie)
                                .listRowInsets(EdgeInsets(top: 6, leading: 0, bottom: 6, trailing: 0))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .scrollIndicators(.hidden)
                .background(Color.clear)
                .scrollDismissesKeyboard(.interactively)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
        .overlay(alignment: .top) {
            SearchListTopFeather()
                .padding(.top, 58)
                .padding(.horizontal, 20)
        }
        .contentShape(Rectangle())
        .simultaneousGesture(
            TapGesture().onEnded {
                dismissKeyboard()
            }
        )
        .toolbarBackground(SystemTheme.background, for: .navigationBar)
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

    private var showingRecentSearches: Bool {
        viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func dismissKeyboard() {
        isSearchFieldFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    @ViewBuilder
    private func recentSearchRow(for movie: Movie) -> some View {
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
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            if showingRecentSearches {
                Button(role: .destructive) {
                    viewModel.removeCachedSearch(movie)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

private struct SearchListTopFeather: View {
    var body: some View {
        LinearGradient(
            colors: [
                SystemTheme.background,
                SystemTheme.background.opacity(0.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 36)
        .allowsHitTesting(false)
    }
}

#Preview {
    SearchView(
        viewModel: PreviewSupport.searchViewModel,
        watchlistState: PreviewSupport.watchlistState
    )
}
