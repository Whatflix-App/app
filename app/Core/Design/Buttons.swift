import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color.accentColor.opacity(configuration.isPressed ? 0.7 : 1.0))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    VStack(spacing: 12) {
        Button("Primary Action") {}
            .buttonStyle(PrimaryButtonStyle())
        Button("Disabled") {}
            .buttonStyle(PrimaryButtonStyle())
            .disabled(true)
    }
    .padding()
}
