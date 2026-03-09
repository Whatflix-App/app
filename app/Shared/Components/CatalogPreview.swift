import SwiftUI

struct CatalogPreview: View {
    var cornerRadius: CGFloat = 16
    var aspectRatio: CGFloat = 3 / 4

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color(.secondarySystemBackground))
            .aspectRatio(aspectRatio, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.primary.opacity(0.15), lineWidth: 1)
            )
    }
}

#Preview {
    CatalogPreview()
        .padding()
}
