import SwiftUI

struct AppStyle {
    static var brandGradient: LinearGradient {
        LinearGradient(
            colors: [
                FlicksColors.background,
                FlicksColors.background
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
