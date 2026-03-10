import SwiftUI

struct MovieCardMiniView: View {
    let movie: Movie?
    let watchlistState: WatchlistState?
    let title: String
    let dateWatched: Date?
    let overview: String?
    let imageName: String?
    var prefix: String = "Watched on"
    var onTap: (() -> Void)? = nil
    @State private var showsDetailSheet = false

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)

                subtitleView
            }
            Spacer()
        }
        .padding()
        .background {
            Color(white: 0.2)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.15), lineWidth: 0.8)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .onTapGesture {
            onTap?()
            showsDetailSheet = true
        }
        .sheet(isPresented: $showsDetailSheet) {
            MovieDetailView(movie: detailMovie, watchlistState: watchlistState)
            .presentationDetents([.large, .large])
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var subtitleView: some View {
        if let dateWatched {
            if prefix == "Watched on" && dateWatched.watchLabel == "Today" {
                Text("Watched Today")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            } else {
                Text("\(prefix) \(dateWatched.watchLabel)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.8))
            }
        } else if !genreText.isEmpty {
            Text(genreText)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.85))
                .lineLimit(2)
        } else {
            Text("No genres available")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.65))
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
        title: "Interstellar",
        dateWatched: Date(),
        overview: nil,
        imageName: nil
    )
        .padding()
}
