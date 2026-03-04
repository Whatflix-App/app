import Foundation
import Combine

@MainActor
final class ForYouViewModel: ObservableObject {
    @Published var title = "For You"
    @Published private(set) var recommendations: [Movie] = []

    private let service: any ForYouServicing

    init(service: any ForYouServicing) {
        self.service = service
    }

    func load() async {
        recommendations = (try? await service.fetchRecommendations()) ?? []
    }
}
