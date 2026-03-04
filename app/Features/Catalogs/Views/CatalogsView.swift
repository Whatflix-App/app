import SwiftUI

struct CatalogsView: View {
    @StateObject var viewModel: CatalogsViewModel

    var body: some View {
        NavigationStack {
            Text(viewModel.title)
                .font(FlicksTypography.screenTitle)
                .navigationTitle("Other Catalogs")
        }
    }
}
