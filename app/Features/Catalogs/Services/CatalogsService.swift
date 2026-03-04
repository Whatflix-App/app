import Foundation

final class CatalogsService {
    private let apiClient: any APIClienting

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    func fetchCatalogs() async throws -> [Catalog] {
        _ = apiClient
        return [Catalog(id: UUID(), name: "Other Catalogs")]
    }
}
