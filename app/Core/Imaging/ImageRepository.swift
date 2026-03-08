import Foundation
import UIKit

actor ImageRepository {
    static let shared = ImageRepository()

    private let session: URLSession
    private let memoryImageCache = NSCache<NSString, UIImage>()
    private let diskCache: DiskImageCache

    private var paletteCache: [String: [UIColor]] = [:]
    private var inFlight: [String: Task<UIImage?, Never>] = [:]

    init(session: URLSession = .shared, diskCache: DiskImageCache = DiskImageCache()) {
        self.session = session
        self.diskCache = diskCache
        memoryImageCache.countLimit = 300
        memoryImageCache.totalCostLimit = 80 * 1024 * 1024
    }

    func image(for path: String?) async -> UIImage? {
        guard let source = Self.resolveSource(from: path) else { return nil }
        return await image(for: source)
    }

    func image(for movie: Movie) async -> UIImage? {
        await image(for: movie.backdropPath)
    }

    func palette(for path: String?) async -> [UIColor] {
        guard let source = Self.resolveSource(from: path) else { return [] }
        return await palette(for: source)
    }

    func palette(for movie: Movie) async -> [UIColor] {
        await palette(for: movie.backdropPath)
    }

    private func image(for source: ImageSource) async -> UIImage? {
        let key = source.cacheKey as NSString

        if let cached = memoryImageCache.object(forKey: key) {
            return cached
        }

        if let data = try? await diskCache.readData(forKey: source.cacheKey),
           let image = UIImage(data: data) {
            memoryImageCache.setObject(image, forKey: key, cost: data.count)
            return image
        }

        if let inFlightTask = inFlight[source.cacheKey] {
            return await inFlightTask.value
        }

        let task = Task<UIImage?, Never> {
            switch source {
            case .local(let name):
                guard let image = UIImage(named: name) else { return nil }
                if let png = image.pngData() {
                    try? await diskCache.write(data: png, forKey: source.cacheKey)
                    memoryImageCache.setObject(image, forKey: key, cost: png.count)
                } else {
                    memoryImageCache.setObject(image, forKey: key)
                }
                return image

            case .remote(let url):
                do {
                    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
                    let (data, response) = try await session.data(for: request)
                    guard let http = response as? HTTPURLResponse,
                          200..<300 ~= http.statusCode,
                          let image = UIImage(data: data) else {
                        return nil
                    }

                    memoryImageCache.setObject(image, forKey: key, cost: data.count)
                    try? await diskCache.write(data: data, forKey: source.cacheKey)
                    return image
                } catch {
                    return nil
                }
            }
        }

        inFlight[source.cacheKey] = task
        let result = await task.value
        inFlight[source.cacheKey] = nil
        return result
    }

    private func palette(for source: ImageSource) async -> [UIColor] {
        if let cached = paletteCache[source.cacheKey] {
            return cached
        }

        guard let image = await image(for: source) else { return [] }
        let colors = await MainActor.run {
            ColorPalette.dominantColors(from: image)
        }
        paletteCache[source.cacheKey] = colors
        return colors
    }
}

private extension ImageRepository {
    enum ImageSource {
        case remote(URL)
        case local(String)

        var cacheKey: String {
            switch self {
            case .remote(let url):
                return "remote:\(url.absoluteString)"
            case .local(let name):
                return "local:\(name)"
            }
        }
    }

    static func resolveSource(from rawPath: String?) -> ImageSource? {
        guard let path = rawPath?.trimmingCharacters(in: .whitespacesAndNewlines), !path.isEmpty else {
            return nil
        }

        if path.hasPrefix("http"), let url = URL(string: path) {
            return .remote(url)
        }

        if path.hasPrefix("/") {
            let absolute = "https://image.tmdb.org/t/p/w780\(path)"
            if let url = URL(string: absolute) {
                return .remote(url)
            }
        }

        return .local(path)
    }
}
