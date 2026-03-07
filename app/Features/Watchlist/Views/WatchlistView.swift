import SwiftUI

struct WatchlistView: View {
    @ObservedObject var viewModel: WatchlistViewModel

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewModel.title)
                    .font(FlicksTypography.screenTitle)

                if viewModel.items.isEmpty {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(0..<6, id: \.self) { _ in
                                MovieCardPreview()
                            }
                        }
                        .padding(.horizontal)
                    }
                } else {
                    List {
                        ForEach(viewModel.items) { movie in
                            MovieCardPreview()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                                .listRowSeparator(.hidden)
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        Task { await viewModel.delete(movie: movie) }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .padding(.vertical)
            .navigationTitle("Primary Save List")
            .task { await viewModel.load() }
        }
    }
}

#Preview {
    WatchlistView(viewModel: PreviewSupport.watchlistViewModel)
}
