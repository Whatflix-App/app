import Foundation

final class ProfileService {
    private struct ProfileDTO: Decodable {
        let id: String
        let email: String?
        let displayName: String?
        let fullName: String?
    }

    private struct WatchHistoryListDTO: Decodable {
        let items: [WatchHistoryItemDTO]
    }

    private struct WatchHistoryItemDTO: Decodable {
        let id: String
        let movieId: String
        let watchedAt: Date
        let completed: Bool
        let progressPct: Int
        let source: String
    }

    private struct SearchMovieItemDTO: Decodable {
        let movieId: String
        let title: String
        let overview: String
        let genreIds: [Int]
        let genres: [String]
        let backdropPath: String?
        let releaseDate: String?
        let runtimeMinutes: Int?
        let voteAverage: Double
        let voteCount: Int
        let popularity: Double
        let adult: Bool
        let originalLanguage: String?
    }

    private let apiClient: any APIClienting

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    func fetchProfile() async throws -> User {
        let data = try await apiClient.send(Endpoint.profile)
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(ProfileDTO.self, from: data)
            return User(
                id: decoded.id,
                email: decoded.email,
                displayName: decoded.displayName,
                fullName: decoded.fullName
            )
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    func fetchWatchHistory() async throws -> [WatchHistoryEntry] {
        let data = try await apiClient.send(Endpoint.watchHistory)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(WatchHistoryListDTO.self, from: data)
        var history: [WatchHistoryEntry] = []
        history.reserveCapacity(decoded.items.count)

        for item in decoded.items {
            let movie = try? await fetchMovie(movieID: item.movieId)
            history.append(Self.mapWatchHistoryItem(item, movie: movie))
        }

        return history
    }

    func updateProfile(displayName: String?) async throws -> User {
        let data = try await apiClient.send(try Endpoint.updateProfile(displayName: displayName))
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(ProfileDTO.self, from: data)
            return User(
                id: decoded.id,
                email: decoded.email,
                displayName: decoded.displayName,
                fullName: decoded.fullName
            )
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    private func fetchMovie(movieID: String) async throws -> Movie {
        let data = try await apiClient.send(Endpoint.searchMovieByID(movieID))
        let decoder = JSONDecoder()
        let dto = try decoder.decode(SearchMovieItemDTO.self, from: data)
        return Movie(
            id: Self.uuidFromString(dto.movieId),
            title: dto.title,
            overview: dto.overview,
            genres: dto.genres,
            movieId: dto.movieId,
            backdropPath: dto.backdropPath,
            releaseDate: dto.releaseDate,
            runtimeMinutes: dto.runtimeMinutes,
            voteAverage: dto.voteAverage,
            voteCount: dto.voteCount,
            popularity: dto.popularity,
            adult: dto.adult,
            originalLanguage: dto.originalLanguage
        )
    }

    private static func mapWatchHistoryItem(_ item: WatchHistoryItemDTO, movie: Movie?) -> WatchHistoryEntry {
        WatchHistoryEntry(
            id: item.id,
            movieId: item.movieId,
            watchedAt: item.watchedAt,
            completed: item.completed,
            progressPct: item.progressPct,
            source: item.source,
            movie: movie
        )
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
