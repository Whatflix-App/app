import SwiftUI

struct MovieDetailPopupView: View {
    @StateObject var viewModel: MovieDetailViewModel

    var body: some View {
        Text(viewModel.detailPopupTitle)
            .font(FlicksTypography.screenTitle)
            .padding()
            .flicksCardStyle()
    }
}
