import SwiftUI

struct MovieCardFullScreenView: View {
    @ObservedObject var viewModel: MovieDetailViewModel

    var body: some View {
        NavigationStack {
            VStack {
                MoviePosterSheetCard(
                    title: viewModel.fullScreenTitle,
                    detailTitle: viewModel.detailPopupTitle
                )
            }
            .padding()
            .navigationTitle("Movie Card")
        }
    }
}

#Preview {
    MovieCardFullScreenView(viewModel: PreviewSupport.movieDetailViewModel)
}
