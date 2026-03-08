import SwiftUI
import UIKit

struct MovieDetailView: View {
    let movie: Movie
    private let watchlistService: WatchlistService
    private let watchlistState: WatchlistState?

    @Environment(\.dismiss) private var dismiss
    @State private var appearSpin = true
    @State private var loadedImage: UIImage?
    @State private var backgroundGradient: LinearGradient?
    @State private var loadTask: Task<Void, Never>?
    @State private var isInWatchlist = false
    @State private var isWatchlistLoading = false

    private let maxContentWidth: CGFloat = 700

    init(
        movie: Movie,
        watchlistService: WatchlistService = WatchlistService(apiClient: AppEnvironment.live.apiClient),
        watchlistState: WatchlistState? = nil
    ) {
        self.movie = movie
        self.watchlistService = watchlistService
        self.watchlistState = watchlistState
    }

    var body: some View {
        GeometryReader { proxy in
            let deviceWidth = max(proxy.size.width, 1)
            let contentWidth = max(min(deviceWidth, maxContentWidth), 1)
            let heroWidth = max(contentWidth - 32, 1)

            ZStack {
                (backgroundGradient ?? AppStyle.brandGradient)
                    .ignoresSafeArea()

                ScrollView {
                    VStack {
                        VStack(alignment: .leading, spacing: 16) {
                            heroImageView(width: heroWidth)

                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(movie.title)
                                            .font(.title2).bold()
                                            .foregroundStyle(.primary)
                                        Text(genreLabel)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }
                                    Spacer()
                                    Button {
                                        withAnimation(.snappy(duration: 0.3, extraBounce: 0.05)) {
                                            appearSpin = true
                                        }
                                        dismiss()
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                    .accessibilityLabel("Close")
                                }

                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Ratings")
                                        .font(.headline)
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 12) {
                                            ratingBadge(title: "TMDB", value: qualityScoreLabel)
                                                .fixedSize(horizontal: true, vertical: false)
                                            ratingBadge(title: "Confidence", value: confidenceLabel)
                                                .fixedSize(horizontal: true, vertical: false)
                                            ratingBadge(title: "Votes", value: voteCountBadgeValue)
                                                .fixedSize(horizontal: true, vertical: false)
                                        }
                                    }
                                }
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Overview")
                                        .font(.headline)
                                    Text(overviewText)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(6)
                                }

                            }
                            .padding(20)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        }
                        .padding(16)
                        .frame(width: contentWidth, alignment: .center)
                    }
                    .padding(.bottom, 84)
                    .frame(maxWidth: .infinity)
                }
                .scaleEffect(appearSpin ? 0.95 : 1.0)
                .opacity(appearSpin ? 0.0 : 1.0)
                .onAppear {
                    withAnimation(.snappy(duration: 0.35, extraBounce: 0.05)) {
                        appearSpin = false
                    }
                    if let movieID = watchlistMovieID, let watchlistState {
                        isInWatchlist = watchlistState.contains(movieID: movieID)
                    }
                    loadImage()
                }
                .onChange(of: movie.id) { _, _ in
                    loadedImage = nil
                    backgroundGradient = nil
                    if let movieID = watchlistMovieID, let watchlistState {
                        isInWatchlist = watchlistState.contains(movieID: movieID)
                    } else {
                        isInWatchlist = false
                    }
                    loadImage()
                }
                .onDisappear {
                    loadTask?.cancel()
                    loadTask = nil
                }

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button {
                            Task { await toggleWatchlist() }
                        } label: {
                            Image(systemName: isInWatchlist ? "bookmark.fill" : "bookmark")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(.black.opacity(0.35))
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(isInWatchlist ? "Remove from watchlist" : "Add to watchlist")
                        .padding(.trailing, 24)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
    }

    private func ratingBadge(title: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(value)
                .font(.headline).bold()
                .lineLimit(1)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

private extension MovieDetailView {
    var imageName: String {
        movie.backdropPath ?? ""
    }

    var imageURL: URL? {
        guard !imageName.isEmpty else { return nil }
        if imageName.hasPrefix("http"), let url = URL(string: imageName) {
            return url
        }
        if imageName.hasPrefix("/") {
            return URL(string: "https://image.tmdb.org/t/p/w780\(imageName)")
        }
        return nil
    }

    func loadImage() {
        loadTask?.cancel()
        loadTask = Task {
            let image = await ImageRepository.shared.image(for: movie)
            let palette = await ImageRepository.shared.palette(for: movie)
            if Task.isCancelled { return }
            loadedImage = image
            if let gradient = AppStyle.gradient(from: palette) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    backgroundGradient = gradient
                }
            } else {
                backgroundGradient = nil
            }
        }
    }

    @ViewBuilder
    func heroImageView(width: CGFloat) -> some View {
        Group {
            if let loadedImage {
                Image(uiImage: loadedImage)
                    .resizable()
                    .scaledToFill()
            } else if imageURL != nil || !imageName.isEmpty {
                Color.gray.opacity(0.3)
                    .overlay(ProgressView())
            } else {
                AppStyle.brandGradient
                    .overlay(
                        Image(systemName: "film")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(.white.opacity(0.85))
                    )
            }
        }
        .frame(width: width, height: 240)
        .clipped()
        .cornerRadius(16)
    }

    var qualityScoreLabel: String {
        guard let voteAverage = movie.voteAverage else { return "N/A" }
        return String(format: "%.1f/10", voteAverage)
    }

    var genreLabel: String {
        if !movie.genres.isEmpty {
            return movie.genres.prefix(3).joined(separator: " • ")
        }
        return "Genre unavailable"
    }

    var confidenceLabel: String {
        guard let voteCount = movie.voteCount else { return "Unknown" }
        if voteCount >= 1000 { return "High" }
        if voteCount >= 100 { return "Medium" }
        return "Low"
    }

    var voteCountBadgeValue: String {
        guard let voteCount = movie.voteCount else { return "N/A" }
        return formatVotes(voteCount)
    }

    var overviewText: String {
        let trimmed = movie.overview.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Overview unavailable." : trimmed
    }

    func formatVotes(_ count: Int) -> String {
        if count >= 1000000 {
            return String(format: "%.1fM", Double(count) / 1000000.0)
        }
        if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000.0)
        }
        return "\(count)"
    }

    var watchlistMovieID: String? {
        movie.movieId
    }

    @MainActor
    func toggleWatchlist() async {
        guard let movieID = watchlistMovieID else { return }
        if isWatchlistLoading { return }

        let wasInWatchlist = isInWatchlist
        let nextState = !wasInWatchlist
        isInWatchlist = nextState

        isWatchlistLoading = true
        defer { isWatchlistLoading = false }

        do {
            if let watchlistState {
                if nextState {
                    try await watchlistState.add(movieID: movieID)
                } else {
                    try await watchlistState.remove(movieID: movieID)
                }
            } else {
                if nextState {
                    try await watchlistService.addWatchlistItem(movieID: movieID)
                } else {
                    try await watchlistService.deleteWatchlistItem(movieID: movieID)
                }
            }
        } catch {
            isInWatchlist = wasInWatchlist
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview {
    MovieDetailView(
        movie: Movie(
            id: UUID(),
            title: "Everything Everywhere All At Once",
            overview: "In a galaxy far far away...",
            voteAverage: 7.8,
            voteCount: 2143
        ),
        watchlistService: WatchlistService(apiClient: PreviewSupport.apiClient)
    )
}
