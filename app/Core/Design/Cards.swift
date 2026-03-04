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
