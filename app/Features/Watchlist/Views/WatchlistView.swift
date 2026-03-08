import SwiftUI
import Combine

struct WatchlistView: View {
    @ObservedObject var viewModel: WatchlistViewModel
    let searchViewModel: SearchViewModel
    let watchlistState: WatchlistState
    @State private var showsSearch = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppStyle.brandGradient
                    .ignoresSafeArea()

                ScrollView(.vertical) {
                    VStack(spacing: 20) {
                        if viewModel.items.isEmpty {
                            EmptyStateView(title: "Start saving movies.")
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.top, 48)
                        } else {
                            ForEach(viewModel.items) { movie in
                                MovieCardPreview(
                                    movie: movie,
                                    watchlistState: watchlistState,
                                    title: movie.title,
                                    subtitle: movie.overview,
                                    imageName: movie.backdropPath,
                                    dateAdded: Date(),
                                    cornerRadius: 20,
                                    aspectRatio: 16 / 9,
                                    showBorder: false
                                )
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        Task { await viewModel.delete(movie: movie) }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 16)
                }
                .scrollIndicators(.hidden)

                LinearGradient(
                    colors: [.clear, .black.opacity(0.45)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 130)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(edges: .bottom)
                .allowsHitTesting(false)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            showsSearch = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 60, height: 60)
                                .glassEffect(in: Circle())
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackground(FlicksColors.background, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .navigationDestination(isPresented: $showsSearch) {
                SearchOverlayView(viewModel: searchViewModel, watchlistState: watchlistState)
                    .onDisappear {
                        Task { await viewModel.load() }
                    }
            }
            .task { await viewModel.load() }
            .onReceive(watchlistState.$movieIDs.dropFirst()) { _ in
                viewModel.pruneItems(keeping: watchlistState.movieIDs)
            }
        }
    }
}

#Preview {
    WatchlistView(
        viewModel: PreviewSupport.watchlistViewModel,
        searchViewModel: PreviewSupport.searchViewModel,
        watchlistState: PreviewSupport.watchlistState
    )
}
