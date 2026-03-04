import SwiftUI

struct WatchlistView: View {
    @StateObject var viewModel: WatchlistViewModel

    var body: some View {
        NavigationStack {
            Text(viewModel.title)
                .font(FlicksTypography.screenTitle)
                .navigationTitle("Primary Save List")
        }
    }
}
