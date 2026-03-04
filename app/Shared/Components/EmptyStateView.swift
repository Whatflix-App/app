import SwiftUI

struct EmptyStateView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(FlicksTypography.body)
            .foregroundStyle(.secondary)
    }
}
