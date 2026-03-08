import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showingLogoutConfirmation = false

    private let genres: [String] = ["Adventure", "Sci-Fi", "Drama", "Thriller"]

    private struct HistoryItem: Identifiable {
        let id = UUID()
        let title: String
    }

    private let history: [HistoryItem] = [
        HistoryItem(title: "Iron Man"),
        HistoryItem(title: "Interstellar"),
        HistoryItem(title: "Everything Everywhere")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppStyle.brandGradient
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header
                        genreSection
                        historySection
                        logoutSection
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .task {
                await viewModel.load()
            }
            .confirmationDialog(
                "Log out?",
                isPresented: $showingLogoutConfirmation,
                titleVisibility: .visible
            ) {
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
                    .foregroundStyle(.white)

                Text(viewModel.email.isEmpty ? "Movie lover" : viewModel.email)
                    .font(.system(size: 15))
                    .foregroundStyle(.white.opacity(0.75))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var genreSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Genres")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(genres, id: \.self) { genre in
                        Text(genre)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .glassEffect(in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.horizontal, -20)
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("History")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.white)

            VStack(spacing: 10) {
                ForEach(history) { movie in
                    MovieCardMiniView(
                        movie: nil,
                        watchlistState: nil,
                        title: movie.title,
                        dateWatched: Date(),
                        overview: nil,
                        imageName: nil
                    )
                }
            }
        }
    }

    private var logoutSection: some View {
        Button {
            showingLogoutConfirmation = true
        } label: {
            Text("Log Out")
                .font(.system(size: 15, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(.white)
                .background(Color.red.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.top, 16)
    }
}

#Preview {
    ProfileView(viewModel: PreviewSupport.profileViewModel)
}
