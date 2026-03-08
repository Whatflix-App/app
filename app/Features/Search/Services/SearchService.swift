import Foundation

protocol SearchServicing {
    func search(query: String) async throws -> [Movie]
}

final class SearchService: SearchServicing {
    private struct SearchItemDTO: Decodable {
        let movieId: String
        let title: String
        let overview: String
        let genreIds: [Int]
        let genres: [String]
        let backdropPath: String?
        let releaseDate: String?
        let voteAverage: Double
        let voteCount: Int
        let popularity: Double
        let adult: Bool
        let originalLanguage: String?
    }

    private struct SearchResponseDTO: Decodable {
        let items: [SearchItemDTO]
    }

    private let apiClient: any APIClienting

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    func search(query: String) async throws -> [Movie] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let data = try await apiClient.send(Endpoint.searchMovies(query: trimmed))
        do {
            let decoded = try JSONDecoder().decode(SearchResponseDTO.self, from: data)
            return decoded.items.map { item in
                Movie(
                    id: Self.uuidFromString(item.movieId),
                    title: item.title,
                    overview: item.overview,
                    genres: item.genres,
                    movieId: item.movieId,
                    backdropPath: item.backdropPath,
                    releaseDate: item.releaseDate,
                    voteAverage: item.voteAverage,
                    voteCount: item.voteCount,
                    popularity: item.popularity,
                    adult: item.adult,
                    originalLanguage: item.originalLanguage
                )
            }
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    private static func uuidFromString(_ value: String) -> UUID {
        if let parsed = UUID(uuidString: value) {
            return parsed
        }

        let hash = value.utf8.reduce(into: UInt64(1469598103934665603)) { result, byte in
            result ^= UInt64(byte)
            result &*= 1099511628211
        }
        let hex = String(format: "%016llx%016llx", hash, hash ^ 0x9e3779b97f4a7c15)
        let segment1 = String(hex.prefix(8))
        let segment2 = String(hex.dropFirst(8).prefix(4))
        let segment3 = String(hex.dropFirst(12).prefix(4))
        let segment4 = String(hex.dropFirst(16).prefix(4))
        let segment5 = String(hex.dropFirst(20).prefix(12))
        let uuidString = "\(segment1)-\(segment2)-\(segment3)-\(segment4)-\(segment5)"
        return UUID(uuidString: uuidString) ?? UUID()
    }
}
