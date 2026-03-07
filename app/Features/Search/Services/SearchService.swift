import Foundation

protocol SearchServicing {
    func search(query: String) async throws -> [Movie]
}

final class SearchService: SearchServicing {
    init(apiClient: any APIClienting) {
        _ = apiClient
    }

    func search(query: String) async throws -> [Movie] {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return [] }
        return [Movie(id: UUID(), title: "Result: \(query)")]
    }
}
