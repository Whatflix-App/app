import SwiftUI

struct MovieRow: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    MovieRow(title: "The Midnight Line")
        .padding()
}
