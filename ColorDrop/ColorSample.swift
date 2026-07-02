import AppKit
import Foundation

struct ColorSample: Equatable {
    let red: Int
    let green: Int
    let blue: Int

    init?(color: NSColor) {
        guard let srgb = color.usingColorSpace(.sRGB) else {
            return nil
        }

        red = Self.componentValue(from: srgb.redComponent)
        green = Self.componentValue(from: srgb.greenComponent)
        blue = Self.componentValue(from: srgb.blueComponent)
    }

    var hex: String {
        String(format: "#%02X%02X%02X", red, green, blue)
    }

    var plainHex: String {
        String(format: "%02X%02X%02X", red, green, blue)
    }

    var rgb: String {
        "rgb(\(red), \(green), \(blue))"
    }

    private static func componentValue(from component: CGFloat) -> Int {
        let scaled = (component * 255).rounded()
        return min(max(Int(scaled), 0), 255)
    }
}
