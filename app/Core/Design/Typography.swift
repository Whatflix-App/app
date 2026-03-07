import SwiftUI

enum FlicksTypography {
    static let screenTitle = Font.title.bold()
    static let body = Font.body
}

#Preview {
    VStack(alignment: .leading, spacing: 8) {
        Text("Screen Title")
            .font(FlicksTypography.screenTitle)
        Text("Body copy style")
            .font(FlicksTypography.body)
    }
    .padding()
}
