import SwiftUI

struct MoviePosterSheetCard: View {
    let title: String
    let detailTitle: String

    @State private var showsDetailSheet = false

    init(title: String, detailTitle: String = "Movie Detail Card") {
        self.title = title
        self.detailTitle = detailTitle
    }

    var body: some View {
        MoviePosterView(title: title)
            .onTapGesture {
                showsDetailSheet = true
            }
            .sheet(isPresented: $showsDetailSheet) {
                VStack(spacing: 16) {
                    MovieCardPreview()
                    Text(detailTitle)
                        .font(FlicksTypography.screenTitle)
                }
                .padding()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)    
            }
    }
}

#Preview {
    MoviePosterSheetCard(title: "The Last Horizon", detailTitle: "The Last Horizon Details")
        .padding()
}
