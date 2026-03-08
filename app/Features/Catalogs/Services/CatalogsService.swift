import Foundation

final class CatalogsService {
    private struct CatalogDTO: Decodable {
        let id: String
        let name: String
        let description: String?
        let isPublic: Bool
        let movieIds: [String]?
    }

    private struct RemoveCatalogResponseDTO: Decodable {
        let ok: Bool
    }

    private let apiClient: any APIClienting

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    func fetchCatalogs() async throws -> [Catalog] {
        let data = try await apiClient.send(Endpoint.catalogs)

        do {
            let decoded = try JSONDecoder().decode([CatalogDTO].self, from: data)
            return decoded.map {
                Catalog(
                    id: $0.id,
                    name: $0.name,
                    description: $0.description,
                    movieIds: $0.movieIds ?? []
                )
            }
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    func createCatalog(name: String, description: String?) async throws -> Catalog {
        let data = try await apiClient.send(
            try Endpoint.createCatalog(name: name, description: description)
        )

        do {
            let decoded = try JSONDecoder().decode(CatalogDTO.self, from: data)
            return Catalog(
                id: decoded.id,
                name: decoded.name,
                description: decoded.description,
                movieIds: decoded.movieIds ?? []
            )
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    func deleteCatalog(id: String) async throws -> Bool {
        let data = try await apiClient.send(Endpoint.deleteCatalog(id: id))

        if data.isEmpty {
            return true
        }

        do {
            return try JSONDecoder().decode(RemoveCatalogResponseDTO.self, from: data).ok
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
