import SwiftUI

struct WatchlistView: View {
    @ObservedObject var viewModel: WatchlistViewModel

    var body: some View {
        NavigationStack {
            Text(viewModel.title)
                .font(FlicksTypography.screenTitle)
                .navigationTitle("Primary Save List")
        }
    }
}
