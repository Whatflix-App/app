import Foundation

final class UserDefaultsStore {
    private let defaults = UserDefaults.standard

    func set(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func bool(forKey key: String) -> Bool {
        defaults.bool(forKey: key)
    }
}
