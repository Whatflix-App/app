import SwiftUI

struct RatingsView: View {
    @ObservedObject var viewModel: RatingsViewModel

    var body: some View {
        NavigationStack {
            Text(viewModel.title)
                .font(FlicksTypography.screenTitle)
                .navigationTitle("Ratings")
        }
    }
}
