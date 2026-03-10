import SwiftUI
import UIKit

enum SystemTheme {
    static let background = Color(
        uiColor: UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(red: 0.07, green: 0.08, blue: 0.10, alpha: 1.0)
            }
            return UIColor(red: 0.97, green: 0.96, blue: 0.94, alpha: 1.0)
        }
    )

    static let primaryText = Color(
        uiColor: UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1.0)
            }
            return UIColor(red: 0.11, green: 0.12, blue: 0.16, alpha: 1.0)
        }
    )

    static let secondaryText = Color(
        uiColor: UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(red: 0.71, green: 0.74, blue: 0.79, alpha: 1.0)
            }
            return UIColor(red: 0.35, green: 0.38, blue: 0.44, alpha: 1.0)
        }
    )

    static let surface = Color(
        uiColor: UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(red: 0.14, green: 0.16, blue: 0.20, alpha: 1.0)
            }
            return UIColor(red: 0.18, green: 0.19, blue: 0.23, alpha: 1.0)
        }
    )

    static let border = Color(
        uiColor: UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor.white.withAlphaComponent(0.12)
            }
            return UIColor.white.withAlphaComponent(0.15)
        }
    )

    static let dotOpacity: CGFloat = 0.12

    static var navigationBarColor: UIColor {
        UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(red: 0.07, green: 0.08, blue: 0.10, alpha: 1.0)
            }
            return UIColor(red: 0.97, green: 0.96, blue: 0.94, alpha: 1.0)
        }
    }

    static var navigationTextColor: UIColor {
        UIColor { trait in
            if trait.userInterfaceStyle == .dark {
                return UIColor(red: 0.94, green: 0.95, blue: 0.97, alpha: 1.0)
            }
            return .black
        }
    }
}

struct SystemScreenBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [SystemTheme.background, SystemTheme.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            SystemDotGridPattern()
                .opacity(SystemTheme.dotOpacity)
        }
    }
}

private struct SystemDotGridPattern: View {
    var spacing: CGFloat = 35
    var dotSize: CGFloat = 1.6

    var body: some View {
        GeometryReader { proxy in
            let columns = Int(ceil(proxy.size.width / spacing)) + 1
            let rows = Int(ceil(proxy.size.height / spacing)) + 1

            Canvas { context, _ in
                for row in 0..<rows {
                    for column in 0..<columns {
                        let x = CGFloat(column) * spacing
                        let y = CGFloat(row) * spacing
                        let rect = CGRect(x: x, y: y, width: dotSize, height: dotSize)
                        context.fill(
                            Path(ellipseIn: rect),
                            with: .color(.white)
                        )
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }
}
