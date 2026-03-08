import SwiftUI

extension View {
    func flicksOverlayStyle() -> some View {
        self.background(.ultraThinMaterial)
    }

    func glassEffect(in shape: some Shape = RoundedRectangle(cornerRadius: 14)) -> some View {
        self.background(.ultraThinMaterial, in: shape)
            .overlay(shape.stroke(.white.opacity(0.2), lineWidth: 0.5))
    }
}
