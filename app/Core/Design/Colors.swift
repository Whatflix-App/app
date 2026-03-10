import SwiftUI

enum FlicksColors {
    static let background = Color(red: 0.97, green: 0.96, blue: 0.94)
    static let primaryText = Color(red: 0.11, green: 0.12, blue: 0.16)
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
