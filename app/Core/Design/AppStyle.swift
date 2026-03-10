import SwiftUI

struct AppStyle {
    static let backgroundDotOpacity: CGFloat = 0.15

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

    @ViewBuilder
    static func screenBackground(gradient: LinearGradient? = nil) -> some View {
        ZStack {
            (gradient ?? brandGradient)
            DotGridPattern()
                .opacity(backgroundDotOpacity)
        }
    }
}

private struct DotGridPattern: View {
    var useLightDots = false
    private let spacing: CGFloat = 25
    private let dotSize: CGFloat = 1.6

    var body: some View {
        GeometryReader { proxy in
            let columns = Int(ceil(proxy.size.width / spacing)) + 1
            let rows = Int(ceil(proxy.size.height / spacing)) + 1
            let dotColor: Color = useLightDots ? .white : .black

            Canvas { context, _ in
                for row in 0..<rows {
                    for column in 0..<columns {
                        let x = CGFloat(column) * spacing
                        let y = CGFloat(row) * spacing
                        let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(dotColor)
                        )
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}
