import SwiftUI

struct MovieRow: View {
    let title: String

    @State private var showsDetailSheet = false

    var body: some View {
        HStack {
            Text(title)
            Spacer()
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            showsDetailSheet = true
        }
        .sheet(isPresented: $showsDetailSheet) {
            MovieDetailView(movie: Movie(id: UUID(), title: title, overview: "No overview available"))
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    MovieRow(title: "The Midnight Line")
        .padding()
}
