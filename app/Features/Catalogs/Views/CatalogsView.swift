import SwiftUI

struct CatalogsView: View {
    @ObservedObject var viewModel: CatalogsViewModel

    var body: some View {
        NavigationStack {
            Text(viewModel.title)
                .font(FlicksTypography.screenTitle)
                .navigationTitle("Other Catalogs")
        }
    }
}
