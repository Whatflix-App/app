import SwiftUI

struct ForYouView: View {
    @StateObject var viewModel: ForYouViewModel
    @StateObject var searchViewModel: SearchViewModel
    @State private var showsSearch = false

    var body: some View {
        NavigationStack {
            Text(viewModel.title)
                .font(FlicksTypography.screenTitle)
                .navigationTitle("For You")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Search") { showsSearch = true }
                    }
                }
                .sheet(isPresented: $showsSearch) {
                    SearchOverlayView(viewModel: searchViewModel)
                }
        }
    }
}
