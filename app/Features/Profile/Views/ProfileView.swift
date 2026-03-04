import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        NavigationStack {
            Text(viewModel.title)
                .font(FlicksTypography.screenTitle)
                .navigationTitle("Profile")
        }
    }
}
