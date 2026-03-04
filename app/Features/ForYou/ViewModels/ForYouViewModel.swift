import Foundation
import Combine

@MainActor
final class ForYouViewModel: ObservableObject {
    @Published var title = "For You"

    private let service: ForYouService

    init(service: ForYouService) {
        self.service = service
    }

    func load() async {
        _ = try? await service.fetchRecommendations()
    }
}
