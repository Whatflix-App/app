import Foundation

enum AppFlags {
    /// Auth stays online by default.
    /// Enable offline bypass with either:
    /// - Launch argument: `--offline-auth-bypass`
    /// - Environment variable: `DISABLE_AUTH_FOR_OFFLINE_TESTING=1`
    static var disableAuthForOfflineTesting: Bool {
        let processInfo = ProcessInfo.processInfo
        if processInfo.arguments.contains("--offline-auth-bypass") {
            return true
        }

        let value = processInfo.environment["DISABLE_AUTH_FOR_OFFLINE_TESTING"]?.lowercased() ?? ""
        return value == "1" || value == "true" || value == "yes"
    }
}
