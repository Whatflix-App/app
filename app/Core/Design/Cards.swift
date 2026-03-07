import SwiftUI

struct FlicksCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

extension View {
    func flicksCardStyle() -> some View {
        modifier(FlicksCardModifier())
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        Text("Featured")
            .font(FlicksTypography.screenTitle)
        Text("A sample card using the shared visual modifier.")
            .font(FlicksTypography.body)
    }
    .flicksCardStyle()
    .padding()
}
