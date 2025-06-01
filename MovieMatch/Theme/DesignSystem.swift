import SwiftUI

// MARK: - Color Extension for Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24,
                            int >> 16 & 0xFF,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        default:
            (a, r, g, b) = (255, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Theme
struct Theme {
    struct Colors {
        static let primary          = Color(hex: "#FF3B5C")
        static let secondary        = Color(hex: "#6C63FF")
        static let backgroundDark   = Color(hex: "#121212")
        static let backgroundMedium = Color(hex: "#1E1E1E")
        static let backgroundLight  = Color(hex: "#2A2A2A")
        static let textPrimary      = Color(hex: "#FFFFFF")
        static let textSecondary    = Color(hex: "#B3B3B3")
        static let textTertiary     = Color(hex: "#757575")
        static let accentSuccess    = Color(hex: "#4CAF50")
        static let accentError      = Color(hex: "#F44336")
        static let accentWarning    = Color(hex: "#FFC107")
    }

    struct Typography {
        static let largeTitle = Font.system(size: 34, weight: .bold)
        static let title1     = Font.system(size: 28, weight: .bold)
        static let title2     = Font.system(size: 22, weight: .bold)
        static let title3     = Font.system(size: 20, weight: .semibold)
        static let bodyLarge  = Font.system(size: 17, weight: .regular)
        static let bodyMedium = Font.system(size: 15, weight: .regular)
        static let bodySmall  = Font.system(size: 13, weight: .regular)
        static let caption    = Font.system(size: 12, weight: .regular)
        static let button     = Font.system(size: 17, weight: .semibold)
    }

    struct Spacing {
        static let unit: CGFloat      = 8
        static let xSmall: CGFloat    = unit        //  8
        static let small: CGFloat     = unit * 2    // 16
        static let medium: CGFloat    = unit * 3    // 24
        static let large: CGFloat     = unit * 4    // 32
        static let xLarge: CGFloat    = unit * 6    // 48
        static let screenEdge: CGFloat = 16
        static let radiusSmall: CGFloat  = 8
        static let radiusMedium: CGFloat = 12
        static let radiusLarge: CGFloat  = 16
    }

    struct IconSize {
        static let small: CGFloat   = 16
        static let medium: CGFloat  = 24
        static let large: CGFloat   = 32
        static let xLarge: CGFloat  = 48
    }
}
