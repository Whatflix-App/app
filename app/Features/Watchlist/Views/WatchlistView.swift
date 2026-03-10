import SwiftUI
import Combine

struct WatchlistView: View {
    @ObservedObject var viewModel: WatchlistViewModel
    let watchlistState: WatchlistState
    @State private var placeholderItems: [PlaceholderItem] = PlaceholderItem.samples

    var body: some View {
        NavigationStack {
            ZStack {
                AppStyle.screenBackground()
                    .ignoresSafeArea()

                MovieCardList {
                    if viewModel.isLoading && viewModel.items.isEmpty {
                        ForEach(0..<4, id: \.self) { _ in
                            WatchlistSkeletonCard()
                                .movieCardListRowStyle()
                        }
                    } else if viewModel.items.isEmpty {
                        ForEach(placeholderItems) { item in
                            MovieCardPreview(
                                title: item.title,
                                subtitle: item.subtitle,
                                imageName: nil,
                                dateAdded: nil,
                                cornerRadius: 20,
                                aspectRatio: 16 / 9,
                                showBorder: false
                            )
                            .opacity(0.72)
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        placeholderItems.removeAll { $0.id == item.id }
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")

                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        placeholderItems.removeAll { $0.id == item.id }
                                    }
                                } label: {
                                    Label("Dislike", systemImage: "hand.thumbsdown.fill")

                                }
                                .tint(.red)
                                Button(role: .destructive) {
                                    withAnimation {
                                        placeholderItems.removeAll { $0.id == item.id }
                                    }
                                } label: {
                                    Label("Neutral", systemImage: "minus")

                                }
                                .tint(.gray)
                                Button(role: .destructive) {
                                    withAnimation {
                                        placeholderItems.removeAll { $0.id == item.id }
                                    }
                                } label: {
                                    Label("Like", systemImage: "hand.thumbsup.fill")
                                }
                                .tint(.green)
                            }
                            .movieCardListRowStyle()
                        }

                        EmptyStateView(title: "Start saving movies.")
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 12)
                            .foregroundStyle(FlicksColors.primaryText.opacity(0.75))
                            .movieCardListRowStyle()
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
                            .swipeActions(edge: .leading, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    Task { await viewModel.delete(movie: movie) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    // method call
                                } label: {
                                    Label("Dislike", systemImage: "hand.thumbsdown.fill")

                                }
                                .tint(.red)
                                Button(role: .destructive) {
                                    // method call
                                } label: {
                                    Label("Neutral", systemImage: "minus")

                                }
                                .tint(.gray)
                                Button(role: .destructive) {
                                    // method call
                                } label: {
                                    Label("Like", systemImage: "hand.thumbsup.fill")
                                }
                                .tint(.green)
                            }
                            .movieCardListRowStyle()
                        }
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbarBackground(FlicksColors.background, for: .tabBar)
            .toolbarBackground(.visible, for: .tabBar)
            .task { await viewModel.load() }
            .onReceive(watchlistState.$movieIDs.dropFirst()) { _ in
                Task {
                    await viewModel.reconcile(with: watchlistState.movieIDs)
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
}

private struct PlaceholderItem: Identifiable {
    var id: String { title }
    let title: String
    let subtitle: String

    static let samples: [PlaceholderItem] = [
        .init(title: "Arrival", subtitle: "Linguist uncovers a deeper mystery."),
        .init(title: "The Grand Budapest Hotel", subtitle: "A concierge's world turns chaotic."),
        .init(title: "Blade Runner 2049", subtitle: "A new blade runner follows a hidden clue.")
    ]
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
        watchlistState: PreviewSupport.watchlistState
    )
}
