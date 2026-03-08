import Foundation
import Combine

@MainActor
final class CatalogState: ObservableObject {
    @Published private(set) var catalogsById: [String: Catalog] = [:]
    @Published private(set) var catalogOrder: [String] = []
    @Published private(set) var movieCatalogIds: [String: Set<String>] = [:]
    @Published private(set) var loadedAt: Date?

    func sync(with catalogs: [Catalog]) {
        catalogsById = Dictionary(uniqueKeysWithValues: catalogs.map { ($0.id, $0) })
        catalogOrder = catalogs.map(\.id)
        rebuildMovieIndex(from: catalogs)
        loadedAt = Date()
    }

    func addOrUpdate(catalog: Catalog) {
        catalogsById[catalog.id] = catalog
        if !catalogOrder.contains(catalog.id) {
            catalogOrder.insert(catalog.id, at: 0)
        }
        rebuildMovieIndex(from: catalogOrder.compactMap { catalogsById[$0] })
        loadedAt = Date()
    }

    func remove(catalogID: String) {
        catalogsById.removeValue(forKey: catalogID)
        catalogOrder.removeAll { $0 == catalogID }
        rebuildMovieIndex(from: catalogOrder.compactMap { catalogsById[$0] })
        loadedAt = Date()
    }

    func catalogsContaining(movieID: String) -> Set<String> {
        movieCatalogIds[movieID] ?? []
    }

    func contains(movieID: String, in catalogID: String) -> Bool {
        movieCatalogIds[movieID]?.contains(catalogID) ?? false
    }

    private func rebuildMovieIndex(from catalogs: [Catalog]) {
        var index: [String: Set<String>] = [:]
        for catalog in catalogs {
            for movieID in catalog.movieIds {
                index[movieID, default: []].insert(catalog.id)
            }
        }
        movieCatalogIds = index
    }
}
