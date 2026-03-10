import Foundation
import Testing
@testable import app

struct AuthServiceTests {
    @Test func refreshIfPossibleUpdatesStoredTokens() async throws {
        let apiClient = MockAPIClient()
        let tokenStore = AuthTokenStore()
        tokenStore.clear()
        tokenStore.save(accessToken: "expired-token", refreshToken: "refresh-1", sessionID: "sess_1")

        let payload = RefreshResponsePayload(
            tokens: AuthTokensPayload(
                accessToken: "access-2",
                accessTokenExpiresAt: Date().addingTimeInterval(900),
                refreshToken: "refresh-2",
                refreshTokenExpiresAt: Date().addingTimeInterval(3600)
            )
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        apiClient.nextData = try encoder.encode(payload)

        let service = AuthService(apiClient: apiClient, tokenStore: tokenStore)
        _ = try await service.refreshIfPossible()

        #expect(tokenStore.accessToken == "access-2")
        #expect(tokenStore.refreshToken() == "refresh-2")
        #expect(tokenStore.sessionID() == "sess_1")
        #expect(apiClient.sentRequests.count == 1)
        #expect(apiClient.sentRequests.first?.path == "auth/refresh")

        tokenStore.clear()
    }

    @Test func refreshIfPossibleWithoutStoredSessionThrowsUnauthorized() async {
        let apiClient = MockAPIClient()
        let tokenStore = AuthTokenStore()
        tokenStore.clear()
        let service = AuthService(apiClient: apiClient, tokenStore: tokenStore)

        do {
            try await service.refreshIfPossible()
            Issue.record("Expected refreshIfPossible() to throw")
        } catch let error as NetworkError {
            switch error {
            case .unauthorized:
                break
            default:
                Issue.record("Expected unauthorized, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
