import SwiftUI

struct LoginView: View {
    @ObservedObject var viewModel: LoginViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(viewModel.title)
                    .font(FlicksTypography.screenTitle)

                Button(viewModel.isLoading ? "Loading..." : "Continue") {
                    Task { await viewModel.login() }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.isLoading)
            }
            .navigationTitle("Auth")
            .padding()
        }
    }
}
