import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var title = "Movie Search"

    private let service: SearchService

    init(service: SearchService) {
        self.service = service
    }

    func runSearch(query: String) async {
        _ = try? await service.search(query: query)
    }
}
