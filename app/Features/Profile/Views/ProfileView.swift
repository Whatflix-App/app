import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(viewModel.title)
                    .font(FlicksTypography.screenTitle)

                Text(viewModel.displayName)
                    .font(.title3.weight(.semibold))

                if !viewModel.email.isEmpty {
                    Text(viewModel.email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                Button("Logout") {
                    Task { await viewModel.logout() }
                }
                .buttonStyle(PrimaryButtonStyle())
            }
            .navigationTitle("Profile")
            .padding()
            .task {
                await viewModel.load()
            }
        }
    }
}

#Preview {
    ProfileView(viewModel: PreviewSupport.profileViewModel)
}
