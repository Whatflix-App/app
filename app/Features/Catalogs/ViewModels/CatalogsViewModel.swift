import Foundation
import Combine

@MainActor
final class CatalogsViewModel: ObservableObject {
    @Published var title = "Catalogs"

    private let service: CatalogsService

    init(service: CatalogsService) {
        self.service = service
    }

    func load() async {
        _ = try? await service.fetchCatalogs()
    }
}
