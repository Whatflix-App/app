import Foundation

final class KeychainStore {
    func save(_ value: String, for key: String) {
        _ = (value, key)
    }

    func read(for key: String) -> String? {
        _ = key
        return nil
    }
}
