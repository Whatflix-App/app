import SwiftUI

struct CatalogPreview: View {
    var body: some View {
        Rectangle()
            .fill(Color(.secondarySystemBackground))
            .frame(width: 150, height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.primary.opacity(0.15), lineWidth: 1)
            )
    }
}

#Preview {
    CatalogPreview()
        .padding()
}
