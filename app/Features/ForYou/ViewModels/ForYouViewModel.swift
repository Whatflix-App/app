import Foundation
import Combine

@MainActor
final class ForYouViewModel: ObservableObject {
    @Published var title = "For You"
    @Published private(set) var recommendations: [Movie] = []

    private var hasLoaded = false

    init() {}

    func load() async {
        guard !hasLoaded else { return }
        hasLoaded = true

        recommendations = [
            Movie(id: UUID(), title: "The Last Horizon"),
            Movie(id: UUID(), title: "Midnight Protocol"),
            Movie(id: UUID(), title: "Glass Ocean"),
            Movie(id: UUID(), title: "Neon Harbor"),
            Movie(id: UUID(), title: "Paper Satellites"),
            Movie(id: UUID(), title: "Echo Archive"),
        ]
    }
}
