import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showingLogoutConfirmation = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppStyle.screenBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        logoutSection
                        genreSection
                        historySection
                    }
                    .padding(20)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await viewModel.load()
            }
            .alert("Log out?", isPresented: $showingLogoutConfirmation) {
                Button("Log Out", role: .destructive) {
                    Task { await viewModel.logout() }
                }
                Button("Cancel", role: .cancel) {}
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 96, height: 96)
                    .overlay(
                        Circle()
                            .strokeBorder(.quaternary, lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 8)

                Image(systemName: "person.crop.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .foregroundStyle(.white)
                    .glassEffect(in: Circle())
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.fullName.isEmpty ? viewModel.displayName : viewModel.fullName)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(FlicksColors.primaryText)

                Text(viewModel.email.isEmpty ? "Movie lover" : viewModel.email)
                    .font(.system(size: 15))
                    .foregroundStyle(FlicksColors.primaryText.opacity(0.75))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var genreSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Genres")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(FlicksColors.primaryText)

            Text("Start watching to claim genres.")
                .font(.system(size: 15))
                .foregroundStyle(FlicksColors.primaryText.opacity(0.75))
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("History")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(FlicksColors.primaryText)

            Text("Start watching to see history.")
                .font(.system(size: 15))
                .foregroundStyle(FlicksColors.primaryText.opacity(0.75))
        }
    }

    private var logoutSection: some View {
        HStack {
            Spacer()
            Button {
                showingLogoutConfirmation = true
            } label: {
                Text("Log Out")
                    .font(.system(size: 15, weight: .bold))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .foregroundStyle(.white)
                    .background(Color.red.opacity(0.75))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    ProfileView(viewModel: PreviewSupport.profileViewModel)
}
