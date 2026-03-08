import SwiftUI

struct VerticalMovieCardView: View {
    let title: String
    let subtitle: String
    let accentColors: [Color]

    @State private var showsDetailSheet = false

    private var gradient: LinearGradient {
        LinearGradient(
            colors: accentColors + [.black.opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Rectangle()
                .fill(gradient)
                .overlay(
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.55), .black.opacity(0.82)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 38, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(2)

                Text(subtitle)
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.85))
                    .lineLimit(2)

                Spacer()
            }
            .padding(24)
        }
        .clipShape(RoundedRectangle(cornerRadius: 0, style: .continuous))
        .contentShape(Rectangle())
        .onTapGesture {
            showsDetailSheet = true
        }
        .sheet(isPresented: $showsDetailSheet) {
            MovieDetailView(movie: Movie(id: UUID(), title: title, overview: subtitle))
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    VerticalMovieCardView(title: "test", subtitle: "test", accentColors: [.red, .green, .blue])
}
