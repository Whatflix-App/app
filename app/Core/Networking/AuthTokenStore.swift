import Foundation

final class AuthTokenStore {
    private(set) var token: String?

    func save(token: String) {
        self.token = token
    }

    func clear() {
        token = nil
    }
}
