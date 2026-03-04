import SwiftUI

struct SearchOverlayView: View {
    @StateObject var viewModel: SearchViewModel

    var body: some View {
        NavigationStack {
            Text(viewModel.title)
                .font(FlicksTypography.screenTitle)
                .navigationTitle("Search")
        }
    }
}
