import Foundation

final class ProfileService {
    private struct ProfileDTO: Decodable {
        let id: String
        let email: String?
        let displayName: String?
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
            return User(id: decoded.id, email: decoded.email, displayName: decoded.displayName)
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    func updateProfile(displayName: String?) async throws -> User {
        let data = try await apiClient.send(try Endpoint.updateProfile(displayName: displayName))
        let decoder = JSONDecoder()
        do {
            let decoded = try decoder.decode(ProfileDTO.self, from: data)
            return User(id: decoded.id, email: decoded.email, displayName: decoded.displayName)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}
