import Foundation
import Combine

@MainActor
final class RatingsViewModel: ObservableObject {
    @Published var title = "Ratings"

    private let service: RatingsService

    init(service: RatingsService) {
        self.service = service
    }

    func load() async {
        _ = try? await service.fetchRatings()
    }
}
