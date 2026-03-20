import SwiftUI
import UIKit

struct MovieDetailView: View {
    let movie: Movie
    private let movieDetailService: MovieDetailService
    private let watchlistService: WatchlistService
    private let watchlistState: WatchlistState?
    private let historyState: HistoryState?

    @Environment(\.dismiss) private var dismiss
    @State private var detailedMovie: Movie?
    @State private var appearSpin = true
    @State private var loadedImage: UIImage?
    @State private var backgroundGradient: LinearGradient?
    @State private var loadTask: Task<Void, Never>?
    @State private var isInWatchlist = false
    @State private var selectedRating: Int?
    @State private var isMovieDetailLoading = false
    @State private var isWatchlistLoading = false
    @State private var isUserStateLoading = false
    @State private var isRatingLoading = false

    private let maxContentWidth: CGFloat = 700

    init(
        movie: Movie,
        movieDetailService: MovieDetailService = MovieDetailService(apiClient: AppEnvironment.live.apiClient),
        watchlistService: WatchlistService = WatchlistService(apiClient: AppEnvironment.live.apiClient),
        watchlistState: WatchlistState? = nil,
        historyState: HistoryState? = nil
    ) {
        self.movie = movie
        self.movieDetailService = movieDetailService
        self.watchlistService = watchlistService
        self.watchlistState = watchlistState
        self.historyState = historyState
        _detailedMovie = State(initialValue: nil)
    }

    var body: some View {
        GeometryReader { proxy in
            let deviceWidth = max(proxy.size.width, 1)
            let contentWidth = max(min(deviceWidth, maxContentWidth), 1)
            let heroWidth = max(contentWidth - 32, 1)

            ZStack {
                AppStyle.screenBackground(gradient: backgroundGradient)
                    .ignoresSafeArea()

                ScrollView {
                    VStack {
                        VStack(alignment: .leading, spacing: 16) {
                            heroImageView(width: heroWidth)

                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(displayMovie.title)
                                            .font(.title2).bold()
                                            .foregroundStyle(.primary)
                                        Text(genreLabel)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                        if let metadataLabel {
                                            Text(metadataLabel)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
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
                    loadImage()
                    Task { await loadMovieDetail() }
                    Task { await loadUserState() }
                }
                .onChange(of: movie.id) { _, _ in
                    detailedMovie = nil
                    loadedImage = nil
                    backgroundGradient = nil
                    isInWatchlist = false
                    selectedRating = nil
                    loadImage()
                    Task { await loadMovieDetail() }
                    Task { await loadUserState() }
                }
                .onDisappear {
                    loadTask?.cancel()
                    loadTask = nil
                }

                VStack {
                    Spacer()
                    HStack {
                        
                        Button {
                            Task { await updateRating(to: -1) }
                        } label: {
                                Image(systemName: selectedRating == -1 ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(.black.opacity(0.35))
                                )
                        }
                        .disabled(isRatingLoading || movie.movieId == nil)
                        .padding(.leading, 50)
                        .padding(.bottom, 20)
                        Button {
                            Task { await updateRating(to: 0) }
                        } label: {
                                Image(systemName: selectedRating == 0 ? "minus.circle.fill" : "minus.circle")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(.black.opacity(0.35))
                                )
                        }
                        .disabled(isRatingLoading || movie.movieId == nil)
                        .padding(.bottom, 20)
                        Button {
                            Task { await updateRating(to: 1) }
                        } label: {
                                Image(systemName: selectedRating == 1 ? "hand.thumbsup.fill" : "hand.thumbsup")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 56, height: 56)
                                .background(
                                    Circle()
                                        .fill(.black.opacity(0.35))
                                )
                        }
                        .disabled(isRatingLoading || movie.movieId == nil)
                        .padding(.bottom, 20)
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
                        .disabled(isWatchlistLoading || movie.movieId == nil)
                        .accessibilityLabel(isInWatchlist ? "Remove from watchlist" : "Add to watchlist")
                        .padding(.trailing, 50)
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
    var displayMovie: Movie {
        detailedMovie ?? movie
    }

    var imageName: String {
        displayMovie.backdropPath ?? ""
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
            let image = await ImageRepository.shared.image(for: displayMovie)
            let palette = await ImageRepository.shared.palette(for: displayMovie)
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
        guard let voteAverage = displayMovie.voteAverage else { return "N/A" }
        return String(format: "%.1f/10", voteAverage)
    }

    var genreLabel: String {
        if !displayMovie.genres.isEmpty {
            return displayMovie.genres.prefix(3).joined(separator: " • ")
        }
        return "Genre unavailable"
    }

    var confidenceLabel: String {
        guard let voteCount = displayMovie.voteCount else { return "Unknown" }
        if voteCount >= 1000 { return "High" }
        if voteCount >= 100 { return "Medium" }
        return "Low"
    }

    var voteCountBadgeValue: String {
        guard let voteCount = displayMovie.voteCount else { return "N/A" }
        return formatVotes(voteCount)
    }

    var overviewText: String {
        let trimmed = displayMovie.overview.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Overview unavailable." : trimmed
    }

    var releaseYear: String? {
        guard let releaseDate = displayMovie.releaseDate, releaseDate.count >= 4 else { return nil }
        return String(releaseDate.prefix(4))
    }

    var runtimeLabel: String? {
        guard let runtimeMinutes = displayMovie.runtimeMinutes, runtimeMinutes > 0 else { return nil }
        let hours = runtimeMinutes / 60
        let minutes = runtimeMinutes % 60

        if hours > 0 && minutes > 0 {
            return "\(hours)h \(minutes)m"
        }
        if hours > 0 {
            return "\(hours)h"
        }
        return "\(minutes)m"
    }

    var metadataLabel: String? {
        [releaseYear, runtimeLabel]
            .compactMap { $0 }
            .joined(separator: " • ")
            .nilIfEmpty
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
        displayMovie.movieId
    }

    @MainActor
    func loadMovieDetail() async {
        guard let movieID = movie.movieId else { return }
        guard !isMovieDetailLoading else { return }

        isMovieDetailLoading = true
        defer { isMovieDetailLoading = false }

        do {
            detailedMovie = try await movieDetailService.fetchMovieDetail(movieID: movieID)
            loadImage()
        } catch {
            detailedMovie = nil
        }
    }

    @MainActor
    func loadUserState() async {
        guard let movieID = watchlistMovieID else { return }
        guard !isUserStateLoading else { return }

        isUserStateLoading = true
        defer { isUserStateLoading = false }

        do {
            let userState = try await movieDetailService.fetchUserState(movieID: movieID)
            isInWatchlist = userState.inWatchlist
            selectedRating = userState.rating?.value

            if let watchlistState {
                if userState.inWatchlist {
                    watchlistState.markAdded(movieID: movieID)
                } else {
                    watchlistState.markRemoved(movieID: movieID)
                }
            }
        } catch {
            if let watchlistState {
                isInWatchlist = watchlistState.contains(movieID: movieID)
            }
        }
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

    @MainActor
    func updateRating(to value: Int) async {
        guard let movieID = movie.movieId else { return }
        guard !isRatingLoading else { return }

        let previousRating = selectedRating
        let isClearing = selectedRating == value
        selectedRating = isClearing ? nil : value
        isRatingLoading = true
        defer { isRatingLoading = false }

        do {
            if isClearing {
                _ = try await movieDetailService.clearMovieRating(movieID: movieID)
                selectedRating = nil
                historyState?.removeRatingEntry(movieID: movieID)
            } else {
                let response = try await movieDetailService.rateMovie(movieID: movieID, rating: value)
                selectedRating = response.rating.value
                historyState?.upsertRatingEntry(
                    movie: displayMovie,
                    movieID: movieID,
                    watchedAt: response.rating.updatedAt
                )
            }
        } catch {
            selectedRating = previousRating
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}

#Preview {
    MovieDetailView(
        movie: Movie(
            id: UUID(),
            title: "Everything Everywhere All At Once",
            overview: "In a galaxy far far away...",
            releaseDate: "2022-03-25",
            runtimeMinutes: 139,
            voteAverage: 7.8,
            voteCount: 2143
        ),
        watchlistService: WatchlistService(apiClient: PreviewSupport.apiClient)
    )
}
