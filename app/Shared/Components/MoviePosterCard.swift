import SwiftUI

struct MoviePosterView: View {
    let title: String

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
    }
}

#Preview {
    MoviePosterView(title: "Whatflix Original")
        .padding()
}
