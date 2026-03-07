import SwiftUI

struct MovieCardPreview: View {
    var body: some View {
        Rectangle()
            .fill(Color(.secondarySystemBackground))
            .frame(width: 220, height: 320)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.primary.opacity(0.15), lineWidth: 1)
            )
    }
}

#Preview {
    MovieCardPreview()
        .padding()
}
