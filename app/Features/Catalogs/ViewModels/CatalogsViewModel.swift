import Foundation
import Combine

@MainActor
final class CatalogsViewModel: ObservableObject {
    @Published var title = "Catalogs"
    @Published private(set) var catalogs: [Catalog] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: CatalogsService

    init(service: CatalogsService) {
        self.service = service
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        catalogs = (try? await service.fetchCatalogs()) ?? []
    }

    func createCatalog(name: String, description: String?, isPublic: Bool) async {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        errorMessage = nil

        do {
            let catalog = try await service.createCatalog(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                description: description?.trimmingCharacters(in: .whitespacesAndNewlines)
            )
            catalogs.insert(catalog, at: 0)
        } catch {
            errorMessage = "Failed to create catalog"
        }
    }

    func deleteCatalog(id: String) async -> Bool {
        errorMessage = nil
        do {
            let ok = try await service.deleteCatalog(id: id)
            if ok {
                catalogs.removeAll { $0.id == id }
            }
            return ok
        } catch {
            errorMessage = "Failed to delete catalog"
            return false
        }
    }
}
