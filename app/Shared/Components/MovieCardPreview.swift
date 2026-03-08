import SwiftUI

struct MovieCardPreview: View {
    let movie: Movie?
    let watchlistState: WatchlistState?
    let title: String
    let subtitle: String?
    let imageName: String?
    let dateAdded: Date?
    let cornerRadius: CGFloat
    let aspectRatio: CGFloat
    let showBorder: Bool

    @State private var showsDetailSheet = false
    @State private var loadedImage: UIImage?
    @State private var imageLoadTask: Task<Void, Never>?

    init(
        movie: Movie? = nil,
        watchlistState: WatchlistState? = nil,
        title: String = "Everything Everywhere All at Once",
        subtitle: String? = "Action · Comedy · Sci-Fi",
        imageName: String? = nil,
        dateAdded: Date? = Date(),
        cornerRadius: CGFloat = 20,
        aspectRatio: CGFloat = 16 / 9,
        showBorder: Bool = true
    ) {
        self.movie = movie
        self.watchlistState = watchlistState
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.dateAdded = dateAdded
        self.cornerRadius = cornerRadius
        self.aspectRatio = aspectRatio
        self.showBorder = showBorder
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            mediaView
                .overlay(alignment: .topTrailing) {
                    if let dateAdded {
                        Text(dateAdded.watchLabel)
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .glassEffect(in: Capsule())
                            .padding(10)
                    }
                }
                .overlay(
                    LinearGradient(
                        colors: [.black.opacity(0.72), .black.opacity(0.1), .clear],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .lineLimit(1)
                }
            }
            .padding(14)
        }
        .aspectRatio(aspectRatio, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay {
            if showBorder {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
        }
        .shadow(color: .black.opacity(0.25), radius: 12, y: 8)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .onTapGesture {
            showsDetailSheet = true
        }
        .onAppear {
            loadImageIfNeeded()
        }
        .onChange(of: imageName) { _, _ in
            loadedImage = nil
            loadImageIfNeeded()
        }
        .onDisappear {
            imageLoadTask?.cancel()
            imageLoadTask = nil
        }
        .sheet(isPresented: $showsDetailSheet) {
            MovieDetailView(movie: detailMovie, watchlistState: watchlistState)
            .presentationDetents([.large, .large])
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var mediaView: some View {
        if let loadedImage {
            Image(uiImage: loadedImage)
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        AppStyle.brandGradient
            .overlay {
                Image(systemName: "film")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.78))
            }
    }

    private var detailMovie: Movie {
        if let movie {
            return movie
        }
        return Movie(
            id: UUID(),
            title: title,
            overview: subtitle ?? "No overview available",
            backdropPath: imageName
        )
    }

    private func loadImageIfNeeded() {
        guard let imageName, !imageName.isEmpty else { return }
        imageLoadTask?.cancel()
        imageLoadTask = Task {
            let image = await ImageRepository.shared.image(for: imageName)
            if Task.isCancelled { return }
            loadedImage = image
        }
    }
}

#Preview {
    MovieCardPreview()
        .padding()
        .background(Color.black)
}
