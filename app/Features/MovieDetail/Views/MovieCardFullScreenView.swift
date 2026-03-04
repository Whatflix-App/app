import SwiftUI

struct MovieCardFullScreenView: View {
    @ObservedObject var viewModel: MovieDetailViewModel

    var body: some View {
        NavigationStack {
            Text(viewModel.fullScreenTitle)
                .font(FlicksTypography.screenTitle)
                .navigationTitle("Movie Card")
        }
    }
}
