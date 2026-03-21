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
    @State private var isOverviewExpanded = false
    @State private var isPeopleExpanded = false

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

                                HStack(spacing: 12) {
                                    ratingBadge(title: "TMDB", value: qualityScoreLabel)
                                        .fixedSize(horizontal: true, vertical: false)
                                    ratingBadge(title: "Year", value: releaseYear ?? "N/A")
                                        .fixedSize(horizontal: true, vertical: false)
                                    ratingBadge(title: "Runtime", value: runtimeLabel ?? "N/A")
                                        .fixedSize(horizontal: true, vertical: false)
                                }
                                .frame(maxWidth: .infinity, alignment: .center)
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Overview")
                                        .font(.headline)
                                    Text(overviewText)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(isOverviewExpanded ? nil : 6)
                                        .contentTransition(.interpolate)
                                    if canExpandOverview {
                                        Text(isOverviewExpanded ? "Tap to collapse" : "Tap to read more")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    guard canExpandOverview else { return }
                                    withAnimation(.snappy(duration: 0.25, extraBounce: 0.02)) {
                                        isOverviewExpanded.toggle()
                                    }
                                }

                            }
                            .padding(20)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 24, style: .continuous))

                            peoplePanel
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
                    isOverviewExpanded = false
                    isPeopleExpanded = false
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
                                .glassEffect(.clear.tint(.black.opacity(0.3)), in: Circle())
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
                                .glassEffect(.clear.tint(.black.opacity(0.3)), in: Circle())
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
                                .glassEffect(.clear.tint(.black.opacity(0.3)), in: Circle())
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
                                .glassEffect(.clear.tint(.black.opacity(0.3)), in: Circle())
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
        HStack(spacing: 4) {
            Text(value)
                .font(.subheadline).bold()
                .lineLimit(1)
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 5)
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

    var overviewText: String {
        let trimmed = displayMovie.overview.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Overview unavailable." : trimmed
    }

    var canExpandOverview: Bool {
        overviewText != "Overview unavailable." && overviewText.count > 220
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

    var hasPeopleContent: Bool {
        displayMovie.director != nil || !displayMovie.cast.isEmpty
    }

    @ViewBuilder
    var peoplePanel: some View {
        if hasPeopleContent {
            VStack(alignment: .leading, spacing: isPeopleExpanded ? 18 : 12) {
                Button {
                    withAnimation(.snappy(duration: 0.3, extraBounce: 0.04)) {
                        isPeopleExpanded.toggle()
                    }
                } label: {
                    HStack(alignment: .center, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("People")
                                .font(.headline)
                                .foregroundStyle(.primary)
                            Text(isPeopleExpanded ? "Director and top cast" : "Tap to view director and cast")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        if !displayMovie.cast.isEmpty {
                            collapsedPeopleAvatars
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                if isPeopleExpanded {
                    VStack(alignment: .leading, spacing: 16) {
                        if let director = displayMovie.director {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Director")
                                    .font(.caption)
                                    .textCase(.uppercase)
                                    .foregroundStyle(.secondary)
                                Text(director)
                                    .font(.body.weight(.semibold))
                                    .foregroundStyle(.primary)
                            }
                        }

                        if !displayMovie.cast.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Top Cast")
                                    .font(.caption)
                                    .textCase(.uppercase)
                                    .foregroundStyle(.secondary)

                                ForEach(displayMovie.cast) { person in
                                    HStack(spacing: 12) {
                                        personAvatar(person, size: 52)

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(person.name)
                                                .font(.body.weight(.semibold))
                                                .foregroundStyle(.primary)
                                            if let role = person.role, !role.isEmpty {
                                                Text(role)
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }

                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(20)
            .glassEffect(in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
    }

    var collapsedPeopleAvatars: some View {
        HStack(spacing: -16) {
            ForEach(Array(displayMovie.cast.prefix(4).enumerated()), id: \.element.id) { index, person in
                personAvatar(person, size: 38)
                    .zIndex(Double(displayMovie.cast.count - index))
            }
        }
        .frame(height: 38)
    }

    @ViewBuilder
    func personAvatar(_ person: Movie.Person, size: CGFloat) -> some View {
        if let url = profileURL(for: person.profilePath) {
            let imageSize = max(size - 4, 1)
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: imageSize, height: imageSize)
                        .clipShape(Circle())
                case .empty:
                    ProgressView()
                        .tint(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .glassEffect(in: Circle())
                case .failure:
                    avatarFallback(size: size)
                @unknown default:
                    avatarFallback(size: size)
                }
            }
            .frame(width: size, height: size)
            .background(
                Circle()
                    .fill(.clear)
                    .glassEffect(in: Circle())
            )
        } else {
            avatarFallback(size: size)
        }
    }

    func avatarFallback(size: CGFloat) -> some View {
        Circle()
            .overlay(
                Image(systemName: "person.fill")
                    .font(.system(size: size * 0.36, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.85))
            )
            .glassEffect(in: Circle())
            .frame(width: size, height: size)
    }

    func profileURL(for profilePath: String?) -> URL? {
        guard let path = profilePath?.trimmingCharacters(in: .whitespacesAndNewlines), !path.isEmpty else {
            return nil
        }
        if path.hasPrefix("http") {
            return URL(string: path)
        }
        if path.hasPrefix("/") {
            return URL(string: "https://image.tmdb.org/t/p/w185\(path)")
        }
        return nil
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
            overview: "When an interdimensional rupture unravels reality, an unlikely hero has to reconnect with her family to hold everything together.",
            genres: ["Sci-Fi", "Adventure", "Comedy"],
            backdropPath: "/ss0Os3uWJfQAENILHZUdX8Tt1OC.jpg",
            releaseDate: "2022-03-25",
            runtimeMinutes: 139,
            voteAverage: 7.8,
            voteCount: 2143,
            director: "Daniel Kwan, Daniel Scheinert",
            cast: [
                .init(
                    id: "1",
                    name: "Michelle Yeoh",
                    role: "Evelyn Wang",
                    profilePath: "/1j8kqVLg6s3g8u0D9w0w0Fz8R4f.jpg",
                    order: 0
                ),
                .init(
                    id: "2",
                    name: "Ke Huy Quan",
                    role: "Waymond Wang",
                    profilePath: "/v48a6UH7x3cvLqDE7K5K4je2xQf.jpg",
                    order: 1
                ),
                .init(
                    id: "3",
                    name: "Stephanie Hsu",
                    role: "Joy Wang",
                    profilePath: "/nM8w5K5e9qg2Yh6U6j2Jq8bK7m5.jpg",
                    order: 2
                )
            ]
        ),
        watchlistService: WatchlistService(apiClient: PreviewSupport.apiClient)
    )
}
