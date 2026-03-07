import SwiftUI

enum FlicksColors {
    static let background = Color(.systemBackground)
    static let primaryText = Color.primary
}

#Preview {
    VStack(spacing: 12) {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(FlicksColors.background)
            .frame(height: 64)
            .overlay(
                Text("Background")
                    .foregroundStyle(FlicksColors.primaryText)
            )
        Text("Primary Text")
            .foregroundStyle(FlicksColors.primaryText)
    }
    .padding()
    .background(Color.gray.opacity(0.2))
}
