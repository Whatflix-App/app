import Foundation

final class AuthTokenStore {
    private enum Keys {
        static let refreshToken = "auth.refreshToken"
        static let sessionID = "auth.sessionId"
    }

    private let keychain: KeychainStore
    private(set) var accessToken: String?

    init(keychain: KeychainStore = KeychainStore()) {
        self.keychain = keychain
    }

    var hasStoredSession: Bool {
        refreshToken() != nil && sessionID() != nil
    }

    func save(accessToken: String, refreshToken: String, sessionID: String) {
        self.accessToken = accessToken
        keychain.save(refreshToken, for: Keys.refreshToken)
        keychain.save(sessionID, for: Keys.sessionID)
    }

    func updateAccessToken(_ accessToken: String) {
        self.accessToken = accessToken
    }

    func updateRefreshToken(_ refreshToken: String) {
        keychain.save(refreshToken, for: Keys.refreshToken)
    }

    func refreshToken() -> String? {
        keychain.read(for: Keys.refreshToken)
    }

    func sessionID() -> String? {
        keychain.read(for: Keys.sessionID)
    }

    func clear() {
        accessToken = nil
        keychain.delete(for: Keys.refreshToken)
        keychain.delete(for: Keys.sessionID)
    }
}
