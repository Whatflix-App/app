import Foundation

protocol SearchServicing {
    func search(query: String) async throws -> [Movie]
}

final class SearchService: SearchServicing {
    private struct SearchResultDTO: Decodable {
        let id: UUID
        let title: String
    }

    private let apiClient: any APIClienting

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    func search(query: String) async throws -> [Movie] {
        let path = "search?q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        let data = try await apiClient.send(APIRequest(path: path, method: "GET"))

        if data.isEmpty {
            return [Movie(id: UUID(), title: "Movie Search")]
        }

        let decoded = try JSONDecoder().decode([SearchResultDTO].self, from: data)
        return decoded.map { Movie(id: $0.id, title: $0.title) }
    }
}
