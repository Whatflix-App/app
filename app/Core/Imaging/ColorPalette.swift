import UIKit

enum ColorPalette {
    static func dominantColors(
        from image: UIImage,
        maxColorCount: Int = 5,
        sampleSize: CGSize = CGSize(width: 40, height: 40)
    ) -> [UIColor] {
        guard let cgImage = image.cgImage else { return [] }

        let width = Int(sampleSize.width)
        let height = Int(sampleSize.height)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8

        var pixels = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        guard let ctx = CGContext(
            data: &pixels,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return []
        }

        ctx.interpolationQuality = .low
        ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        struct Bin {
            var count: Int = 0
            var rSum: Int = 0
            var gSum: Int = 0
            var bSum: Int = 0
        }

        var bins: [Int: Bin] = [:]
        bins.reserveCapacity(256)

        for y in stride(from: 0, to: height, by: 2) {
            for x in stride(from: 0, to: width, by: 2) {
                let offset = (y * width + x) * bytesPerPixel
                let r = Int(pixels[offset])
                let g = Int(pixels[offset + 1])
                let b = Int(pixels[offset + 2])
                let a = Int(pixels[offset + 3])

                if a < 24 { continue }

                let rq = r >> 3
                let gq = g >> 3
                let bq = b >> 3
                let key = (rq << 10) | (gq << 5) | bq

                var bin = bins[key] ?? Bin()
                bin.count += 1
                bin.rSum += r
                bin.gSum += g
                bin.bSum += b
                bins[key] = bin
            }
        }

        guard !bins.isEmpty else { return [] }

        let ranked = bins.values
            .sorted { lhs, rhs in
                lhs.count > rhs.count
            }

        var output: [UIColor] = []
        output.reserveCapacity(maxColorCount)

        for bin in ranked {
            let count = max(bin.count, 1)
            let r = CGFloat(bin.rSum / count) / 255.0
            let g = CGFloat(bin.gSum / count) / 255.0
            let b = CGFloat(bin.bSum / count) / 255.0

            let candidate = UIColor(red: r, green: g, blue: b, alpha: 1.0)
                .saturatedAdjusted(factor: 1.08)

            if !output.contains(where: { $0.isClose(to: candidate, threshold: 0.09) }) {
                output.append(candidate)
                if output.count >= maxColorCount { break }
            }
        }

        return output
    }
}
