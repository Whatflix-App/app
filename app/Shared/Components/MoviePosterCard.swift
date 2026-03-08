import SwiftUI

struct MoviePosterView: View {
    let title: String

    @State private var showsDetailSheet = false

    var body: some View {
        Rectangle()
            .fill(Color(.secondarySystemBackground))
            .overlay(
                VStack(spacing: 12) {
                    Text(title)
                        .font(FlicksTypography.screenTitle)
                }
                .padding(24)
            )
            .frame(maxWidth: .infinity, minHeight: 420)
            .overlay(
                Rectangle()
                    .stroke(Color.primary.opacity(0.15), lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                showsDetailSheet = true
            }
            .sheet(isPresented: $showsDetailSheet) {
                MovieDetailView(movie: Movie(id: UUID(), title: title, overview: "No overview available"))
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
    }
}

#Preview {
    MoviePosterView(title: "Whatflix Original")
        .padding()
}
