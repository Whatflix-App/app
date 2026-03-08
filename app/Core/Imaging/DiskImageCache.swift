import Foundation

struct DiskImageCache {
    private let directoryURL: URL

    nonisolated init() {
        let fm = FileManager.default
        let base = fm.urls(for: .cachesDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        directoryURL = base.appendingPathComponent("whatflix-image-cache", isDirectory: true)
        try? fm.createDirectory(at: directoryURL, withIntermediateDirectories: true)
    }

    nonisolated func readData(forKey key: String) async throws -> Data {
        let fileURL = directoryURL.appendingPathComponent(key.fnvHash)
        return try Data(contentsOf: fileURL)
    }

    nonisolated func write(data: Data, forKey key: String) async throws {
        let fileURL = directoryURL.appendingPathComponent(key.fnvHash)
        try data.write(to: fileURL, options: .atomic)
    }
}

private extension String {
    nonisolated var fnvHash: String {
        let data = Data(self.utf8)
        let digest = data.reduce(into: UInt64(1469598103934665603)) { result, byte in
            result ^= UInt64(byte)
            result &*= 1099511628211
        }
        return String(format: "%016llx%016llx", digest, digest ^ 0x9e3779b97f4a7c15)
    }
}
