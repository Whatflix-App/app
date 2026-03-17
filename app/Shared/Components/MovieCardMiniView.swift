import SwiftUI

struct MovieCardMiniView: View {
    let movie: Movie?
    let watchlistState: WatchlistState?
    let historyState: HistoryState?
    let title: String
    let dateWatched: Date?
    let overview: String?
    let imageName: String?
    var prefix: String = "Watched on"
    var onTap: (() -> Void)? = nil
    let onDetailPresentationChanged: ((Bool) -> Void)?
    @State private var showsDetailSheet = false

    init(
        movie: Movie?,
        watchlistState: WatchlistState?,
        historyState: HistoryState? = nil,
        title: String,
        dateWatched: Date?,
        overview: String?,
        imageName: String?,
        prefix: String = "Watched on",
        onTap: (() -> Void)? = nil,
        onDetailPresentationChanged: ((Bool) -> Void)? = nil
    ) {
        self.movie = movie
        self.watchlistState = watchlistState
        self.historyState = historyState
        self.title = title
        self.dateWatched = dateWatched
        self.overview = overview
        self.imageName = imageName
        self.prefix = prefix
        self.onTap = onTap
        self.onDetailPresentationChanged = onDetailPresentationChanged
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(SystemTheme.primaryText)
                    .lineLimit(1)

                subtitleView
            }
            Spacer()
        }
        .padding()
        .background {
            SystemTheme.surface
        }
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(SystemTheme.border, lineWidth: 0.8)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .onTapGesture {
            onTap?()
            showsDetailSheet = true
        }
        .sheet(isPresented: $showsDetailSheet) {
            MovieDetailView(
                movie: detailMovie,
                watchlistState: watchlistState,
                historyState: historyState
            )
            .presentationDetents([.large, .large])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: showsDetailSheet) { _, isPresented in
            onDetailPresentationChanged?(isPresented)
        }
    }

    @ViewBuilder
    private var subtitleView: some View {
        if let dateWatched {
            if prefix == "Watched on" && dateWatched.watchLabel == "Today" {
                Text("Watched Today")
                    .font(.caption)
                    .foregroundStyle(SystemTheme.secondaryText)
            } else {
                Text("\(prefix) \(dateWatched.watchLabel)")
                    .font(.caption)
                    .foregroundStyle(SystemTheme.secondaryText)
            }
        } else if !genreText.isEmpty {
            Text(genreText)
                .font(.caption)
                .foregroundStyle(SystemTheme.secondaryText)
                .lineLimit(2)
        } else {
            Text("No genres available")
                .font(.caption)
                .foregroundStyle(SystemTheme.secondaryText.opacity(0.8))
        }
    }

    private var detailMovie: Movie {
        if let movie {
            return movie
        }
        return Movie(
            id: UUID(),
            title: title,
            overview: overview ?? "No overview available"
        )
    }

    private var genreText: String {
        if let movie, !movie.genres.isEmpty {
            return movie.genres.prefix(3).joined(separator: " • ")
        }
        return ""
    }
}

#Preview {
    MovieCardMiniView(
        movie: nil,
        watchlistState: nil,
        historyState: nil,
        title: "Interstellar",
        dateWatched: Date(),
        overview: nil,
        imageName: nil,
        onDetailPresentationChanged: nil
    )
        .padding()
}
