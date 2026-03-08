import SwiftUI

struct ForYouView: View {
    @ObservedObject var viewModel: ForYouViewModel
    let searchViewModel: SearchViewModel

    @State private var scrollPosition: UUID?
    @State private var isSearching = false
    @State private var query = ""
    @State private var interactingMovieID: UUID?
    @State private var watchlistSet: Set<UUID> = []

    private struct DisplayMovie: Identifiable {
        let id: UUID
        let title: String
        let subtitle: String
        let colors: [Color]
    }

    private var displayMovies: [DisplayMovie] {
        let subtitles = [
            "Because your circle would watch this tonight",
            "High-match pick for your taste profile",
            "Fresh drop aligned with your vibe",
            "Hidden gem with strong momentum"
        ]

        let palettes: [[Color]] = [
            [Color(red: 0.16, green: 0.27, blue: 0.58), Color(red: 0.42, green: 0.21, blue: 0.53)],
            [Color(red: 0.23, green: 0.52, blue: 0.45), Color(red: 0.18, green: 0.22, blue: 0.56)],
            [Color(red: 0.58, green: 0.32, blue: 0.22), Color(red: 0.33, green: 0.19, blue: 0.45)],
            [Color(red: 0.34, green: 0.23, blue: 0.61), Color(red: 0.14, green: 0.44, blue: 0.52)]
        ]

        let source: [Movie]
        if viewModel.recommendations.isEmpty {
            source = (0..<6).map { index in
                Movie(
                    id: UUID(uuidString: String(format: "00000000-0000-0000-0000-%012d", index + 1))!,
                    title: "Recommended Movie \(index + 1)",
                    overview: "A curated pick for your queue based on your latest watch activity."
                )
            }
        } else {
            source = viewModel.recommendations
        }

        return source.enumerated().map { index, movie in
            DisplayMovie(
                id: movie.id,
                title: movie.title,
                subtitle: subtitles[index % subtitles.count],
                colors: palettes[index % palettes.count]
            )
        }
    }

    private var currentMovieID: UUID? {
        scrollPosition ?? displayMovies.first?.id
    }
    private var currentWatchlistBinding: Binding<Bool> {
        Binding(
            get: {
                guard let currentMovieID else { return false }
                return watchlistSet.contains(currentMovieID)
            },
            set: { newValue in
                guard let currentMovieID else { return }
                if newValue {
                    watchlistSet.insert(currentMovieID)
                } else {
                    watchlistSet.remove(currentMovieID)
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
//            GeometryReader { proxy in
//                ZStack(alignment: .top) {
//                    ScrollView(.vertical) {
//                        LazyVStack(spacing: 0) {
//                            ForEach(displayMovies) { movie in
//                                VerticalMovieCardView(
//                                    title: movie.title,
//                                    subtitle: movie.subtitle,
//                                    accentColors: movie.colors
//                                )
//                                .frame(width: proxy.size.width, height: proxy.size.height)
//                                .id(movie.id)
//                                .onAppear {
//                                    scrollPosition = movie.id
//                                }
//                            }
//                        }
//                        .scrollTargetLayout()
//                    }
//                    .scrollPosition(id: $scrollPosition)
//                    .scrollTargetBehavior(.paging)
//                    .scrollIndicators(.hidden)
//                    .ignoresSafeArea()
//                    .background(.black)
//
//
//                }
//            }
//            .ignoresSafeArea()
//            .task {
//                await viewModel.load()
//                if scrollPosition == nil {
//                    scrollPosition = displayMovies.first?.id
//                }
//            }
            
            HStack {
                Spacer()
                Text("Coming Soon...")
                Spacer()
            }
        }
    }

}

#Preview {
    ForYouView(
        viewModel: PreviewSupport.forYouViewModel,
        searchViewModel: PreviewSupport.searchViewModel
    )
}
