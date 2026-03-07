import SwiftUI

struct ForYouView: View {
    @ObservedObject var viewModel: ForYouViewModel
    @ObservedObject var searchViewModel: SearchViewModel
    @State private var showsSearch = false
    private let placeholderCount = 6

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(viewModel.title)
                    .font(FlicksTypography.screenTitle)

                ScrollView(.vertical, showsIndicators: true) {
                    VStack(spacing: 16) {
                        if viewModel.recommendations.isEmpty {
                            ForEach(0..<placeholderCount, id: \.self) { index in
                                MoviePosterSheetCard(title: "Recommended Movie \(index + 1)")
                            }
                        } else {
                            ForEach(viewModel.recommendations) { movie in
                                MoviePosterSheetCard(
                                    title: movie.title,
                                    detailTitle: "\(movie.title) Details"
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
            .navigationTitle("For You")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Search") { showsSearch = true }
                }
            }
            .sheet(isPresented: $showsSearch) {
                SearchOverlayView(viewModel: searchViewModel)
            }
            .task { await viewModel.load() }
        }
    }
}

#Preview {
    ForYouView(
        viewModel: PreviewSupport.forYouViewModel,
        searchViewModel: PreviewSupport.searchViewModel
    )
}
