import UIKit

extension UIColor {
    var hsbComponents: (h: CGFloat, s: CGFloat, b: CGFloat, a: CGFloat) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            return (h, s, b, a)
        }

        var r: CGFloat = 0
        var g: CGFloat = 0
        var bl: CGFloat = 0
        var alpha: CGFloat = 0
        if self.getRed(&r, green: &g, blue: &bl, alpha: &alpha) {
            let maxV = max(r, max(g, bl))
            let minV = min(r, min(g, bl))
            let delta = maxV - minV

            var hue: CGFloat = 0
            if delta != 0 {
                if maxV == r {
                    hue = (g - bl) / delta
                } else if maxV == g {
                    hue = 2 + (bl - r) / delta
                } else {
                    hue = 4 + (r - g) / delta
                }
                hue /= 6
                if hue < 0 { hue += 1 }
            }

            let brightness = maxV
            let saturation = brightness == 0 ? 0 : (delta / brightness)
            return (hue, saturation, brightness, alpha)
        }

        return (0, 0, 0, 1)
    }

    var saturation: CGFloat {
        hsbComponents.s
    }

    var brightness: CGFloat {
        hsbComponents.b
    }

    var perceivedBrightness: CGFloat {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        if self.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return 0.299 * r + 0.587 * g + 0.114 * b
        }
        return brightness
    }

    func saturatedAdjusted(factor: CGFloat = 1.15) -> UIColor {
        let comps = hsbComponents
        let newS = min(max(comps.s * factor, 0), 1)
        return UIColor(hue: comps.h, saturation: newS, brightness: comps.b, alpha: comps.a)
    }

    func isClose(to other: UIColor, threshold: CGFloat = 0.08) -> Bool {
        let a = self.hsbComponents
        let b = other.hsbComponents
        let dh = min(abs(a.h - b.h), 1 - abs(a.h - b.h))
        let ds = abs(a.s - b.s)
        let db = abs(a.b - b.b)
        let distance = (dh * 0.6) + (ds * 0.25) + (db * 0.15)
        return distance < threshold
    }
}
