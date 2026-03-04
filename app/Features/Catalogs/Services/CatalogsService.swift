import Foundation

final class CatalogsService {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func fetchCatalogs() async throws -> [Catalog] {
        _ = apiClient
        return [Catalog(id: UUID(), name: "Other Catalogs")]
    }
}
