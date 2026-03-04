import SwiftUI

struct ForYouView: View {
    @ObservedObject var viewModel: ForYouViewModel
    @ObservedObject var searchViewModel: SearchViewModel
    @State private var showsSearch = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(viewModel.title)
                    .font(FlicksTypography.screenTitle)

                if let first = viewModel.recommendations.first {
                    Text(first.title)
                }
            }
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
