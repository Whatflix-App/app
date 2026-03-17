import SwiftUI
import Combine

struct WatchlistView: View {
    @ObservedObject var viewModel: WatchlistViewModel
    let watchlistState: WatchlistState
    let historyState: HistoryState
    @State private var isShowingDetail = false
    @State private var pendingMovieIDs: Set<String>?

    var body: some View {
        NavigationStack {
            ZStack {
                SystemScreenBackground()
                    .ignoresSafeArea()

                MovieCardList {
                    if viewModel.isLoading && viewModel.items.isEmpty {
                        ForEach(0..<4, id: \.self) { _ in
                            WatchlistSkeletonCard()
                                .movieCardListRowStyle()
                        }
                    } else if viewModel.items.isEmpty {
                        EmptyStateView(title: "Start saving movies.")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 12)
                            .foregroundStyle(SystemTheme.secondaryText)
                            .movieCardListRowStyle()
                    } else {
                        ForEach(viewModel.items) { movie in
                            MovieCardPreview(
                                movie: movie,
                                watchlistState: watchlistState,
                                historyState: historyState,
                                title: movie.title,
                                subtitle: movie.overview,
                                imageName: movie.backdropPath,
                                dateAdded: Date(),
                                cornerRadius: 20,
                                aspectRatio: 16 / 9,
                                showBorder: false,
                                onDetailPresentationChanged: { isPresented in
                                    handleDetailPresentationChange(isPresented)
                                }
                            )
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task { await viewModel.delete(movie: movie) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .movieCardListRowStyle()
                        }
                    }
                }
            }
            .overlay(alignment: .top) {
                WatchlistTopFeather()
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackground(SystemTheme.background, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .task { await viewModel.load() }
            .onReceive(watchlistState.$movieIDs.dropFirst()) { movieIDs in
                if isShowingDetail {
                    pendingMovieIDs = movieIDs
                    return
                }

                Task {
                    await viewModel.reconcile(with: movieIDs)
                }
            }
            .alert(
                "Couldn't remove movie",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.errorMessage = nil
                        }
                    }
                )
            ) {
                Button("OK", role: .cancel) {
                    viewModel.errorMessage = nil
                }
            } message: {
                Text(viewModel.errorMessage ?? "Something went wrong. Please try again.")
            }
        }
    }

    private func handleDetailPresentationChange(_ isPresented: Bool) {
        isShowingDetail = isPresented

        guard !isPresented, let pendingMovieIDs else { return }
        self.pendingMovieIDs = nil

        Task {
            await viewModel.reconcile(with: pendingMovieIDs)
        }
    }
}

private struct WatchlistTopFeather: View {
    var body: some View {
        LinearGradient(
            colors: [
                SystemTheme.background,
                SystemTheme.background.opacity(0.0)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 48)
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }
}

private struct WatchlistSkeletonCard: View {
    @State private var shimmerOffset: CGFloat = -220

    var body: some View {
        RoundedRectangle(cornerRadius: 20, style: .continuous)
            .fill(Color.black.opacity(0.42))
            .aspectRatio(16 / 9, contentMode: .fit)
            .overlay {
                VStack(alignment: .leading, spacing: 8) {
                    Spacer()
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.white.opacity(0.16))
                        .frame(width: 180, height: 18)
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 240, height: 14)
                }
                .padding(14)
            }
            .overlay {
                LinearGradient(
                    colors: [
                        .white.opacity(0.0),
                        .white.opacity(0.14),
                        .white.opacity(0.0)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: 120)
                .offset(x: shimmerOffset)
                .blendMode(.screen)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .onAppear {
                withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                    shimmerOffset = 220
                }
            }
    }
}

#Preview {
    WatchlistView(
        viewModel: PreviewSupport.watchlistViewModel,
        watchlistState: PreviewSupport.watchlistState,
        historyState: PreviewSupport.historyState
    )
}
