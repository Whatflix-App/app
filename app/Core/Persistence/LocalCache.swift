import Foundation

final class LocalCache {
    private var storage: [String: Data] = [:]

    func set(_ value: Data, for key: String) {
        storage[key] = value
    }

    func data(for key: String) -> Data? {
        storage[key]
    }
}
