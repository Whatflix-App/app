import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(viewModel.title)
                    .font(FlicksTypography.screenTitle)

                Button("Logout") {
                    viewModel.logout()
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .navigationTitle("Profile")
            .padding()
        }
    }
}
