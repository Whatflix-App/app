import Foundation
import UIKit

protocol AuthServicing {
    func loginWithApple(identityToken: String, authorizationCode: String) async throws -> AuthSuccessResponse
    func refreshIfPossible() async throws -> RefreshResponsePayload
    func logout() async
    func pingBackend() async throws
}

final class AuthService: AuthServicing {
    private let apiClient: any APIClienting
    private let tokenStore: AuthTokenStore

    init(apiClient: any APIClienting, tokenStore: AuthTokenStore) {
        self.apiClient = apiClient
        self.tokenStore = tokenStore
    }

    func loginWithApple(identityToken: String, authorizationCode: String) async throws -> AuthSuccessResponse {
        let payload = AppleLoginRequest(
            provider: "apple",
            identityToken: identityToken,
            authorizationCode: authorizationCode,
            device: devicePayload()
        )

        let data = try await apiClient.send(try Endpoint.appleLogin(payload))
        let response = try decode(AuthSuccessResponse.self, from: data)
        persistTokens(from: response)
        return response
    }

    func refreshIfPossible() async throws -> RefreshResponsePayload {
        guard let refreshToken = tokenStore.refreshToken(), let sessionID = tokenStore.sessionID() else {
            throw NetworkError.unauthorized
        }

        let payload = RefreshRequestPayload(refreshToken: refreshToken, sessionId: sessionID)
        let data = try await apiClient.send(try Endpoint.refresh(payload))
        let response = try decode(RefreshResponsePayload.self, from: data)
        tokenStore.updateAccessToken(response.tokens.accessToken)
        tokenStore.updateRefreshToken(response.tokens.refreshToken)
        return response
    }

    func logout() async {
        if let refreshToken = tokenStore.refreshToken(), let sessionID = tokenStore.sessionID() {
            let payload = LogoutRequestPayload(refreshToken: refreshToken, sessionId: sessionID)
            _ = try? await apiClient.send(try Endpoint.logout(payload))
        }

        tokenStore.clear()
    }

    func pingBackend() async throws {
        _ = try await apiClient.send(Endpoint.health)
    }

    private func persistTokens(from response: AuthSuccessResponse) {
        tokenStore.save(
            accessToken: response.tokens.accessToken,
            refreshToken: response.tokens.refreshToken,
            sessionID: response.session.id
        )
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
