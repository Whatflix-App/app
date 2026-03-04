import SwiftUI

struct MoviePosterCard: View {
    let title: String

    var body: some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding()
            .flicksCardStyle()
    }
}
