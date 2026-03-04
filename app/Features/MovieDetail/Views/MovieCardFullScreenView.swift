import SwiftUI

struct MovieCardFullScreenView: View {
    @StateObject var viewModel: MovieDetailViewModel

    var body: some View {
        NavigationStack {
            Text(viewModel.fullScreenTitle)
                .font(FlicksTypography.screenTitle)
                .navigationTitle("Movie Card")
        }
    }
}
