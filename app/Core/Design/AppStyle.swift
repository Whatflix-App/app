import SwiftUI

struct AppStyle {
    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.09, green: 0.11, blue: 0.25),
                Color(red: 0.18, green: 0.19, blue: 0.38),
                Color(red: 0.42, green: 0.31, blue: 0.56)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static func dominantColors(from image: UIImage, sampleGrid: Int = 4) -> [UIColor]? {
        _ = sampleGrid
        let colors = ColorPalette.dominantColors(from: image, maxColorCount: 5)
        return colors.isEmpty ? nil : colors
    }

    static func gradient(from colors: [UIColor]) -> LinearGradient? {
        guard !colors.isEmpty else { return nil }

        let sorted = colors.sorted { a, b in
            a.perceivedBrightness < b.perceivedBrightness
        }

        let gradientColors: [Color]
        if sorted.count == 1, let only = sorted.first {
            gradientColors = [Color(uiColor: only), Color(uiColor: only).opacity(0.72)]
        } else {
            gradientColors = sorted.map { Color(uiColor: $0) }
        }

        return LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
