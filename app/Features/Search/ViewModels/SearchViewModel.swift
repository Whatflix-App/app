import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var title = "Movie Search"
    @Published var query = ""
    @Published private(set) var results: [Movie] = []

    private let service: any SearchServicing

    init(service: any SearchServicing) {
        self.service = service
    }

    func runSearch() async {
        results = (try? await service.search(query: query)) ?? []
    }
}
