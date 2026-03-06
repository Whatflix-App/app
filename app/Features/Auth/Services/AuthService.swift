import Foundation
import UIKit

protocol AuthServicing {
    func loginWithApple(identityToken: String, authorizationCode: String) async throws -> AuthSuccessResponse
    func pingBackend() async throws
}

final class AuthService: AuthServicing {
    private let apiClient: any APIClienting

    init(apiClient: any APIClienting) {
        self.apiClient = apiClient
    }

    func loginWithApple(identityToken: String, authorizationCode: String) async throws -> AuthSuccessResponse {
        let payload = AppleLoginRequest(
            provider: "apple",
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            device: devicePayload()
        )

        let data = try await apiClient.send(try Endpoint.appleLogin(payload))
        return try decode(AuthSuccessResponse.self, from: data)
    }

    func pingBackend() async throws {
        _ = try await apiClient.send(Endpoint.health)
    }

    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    private func devicePayload() -> DevicePayload {
        DevicePayload(
            id: UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString,
            platform: "ios",
            appVersion: Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        )
    }
}
