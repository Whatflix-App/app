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
            Movie(id: UUID(), title: "The Last Horizon", overview: "An expedition crew searches for a habitable world beyond mapped space."),
            Movie(id: UUID(), title: "Midnight Protocol", overview: "A covert team races to stop a digital attack before dawn."),
            Movie(id: UUID(), title: "Glass Ocean", overview: "A survival drama aboard a research vessel trapped in unstable waters."),
            Movie(id: UUID(), title: "Neon Harbor", overview: "A crime thriller set in a futuristic port city with shifting alliances."),
            Movie(id: UUID(), title: "Paper Satellites", overview: "A coming-of-age sci-fi story about friends building signals to the stars."),
            Movie(id: UUID(), title: "Echo Archive", overview: "A memory-tech mystery where deleted histories begin to reappear."),
        ]
    }
}
