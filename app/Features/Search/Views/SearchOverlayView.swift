import SwiftUI

struct SearchOverlayView: View {
    @ObservedObject var viewModel: SearchViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(viewModel.title)
                    .font(FlicksTypography.screenTitle)

                TextField("Search movies", text: $viewModel.query)
                    .textFieldStyle(.roundedBorder)

                Button("Run Search") {
                    Task { await viewModel.runSearch() }
                }
                .buttonStyle(PrimaryButtonStyle())

                if let first = viewModel.results.first {
                    Text(first.title)
                }
            }
            .navigationTitle("Search")
            .padding()
        }
    }
}
