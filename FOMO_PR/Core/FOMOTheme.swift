import SwiftUI

public enum FOMOTheme {
    public enum Colors {
        public static let primary = Color(hex: "#4B0082") // Deep Purple
        public static let secondary = Color.black
        public static let background = Color(hex: "#1A1A1A") // Dark Background
        public static let surface = Color(hex: "#2A2A2A")
        public static let accent = Color.purple
        public static let text = Color.white
        public static let textSecondary = Color.gray
        public static let success = Color.green
        public static let warning = Color.yellow
        public static let error = Color.red
    }
    
    public enum Typography {
        public static let display = Font.system(size: 34, weight: .bold, design: .rounded)
        public static let headlineLarge = Font.system(size: 28, weight: .bold, design: .rounded)
        public static let headlineMedium = Font.system(size: 22, weight: .bold, design: .rounded)
        public static let headlineSmall = Font.system(size: 20, weight: .bold, design: .rounded)
        public static let bodyLarge = Font.system(size: 18)
        public static let bodyRegular = Font.system(size: 16)
        public static let bodySmall = Font.system(size: 14)
        public static let caption1 = Font.system(size: 12)
        public static let caption2 = Font.system(size: 10)
    }
    
    public enum Layout {
        public static let gridSpacing: CGFloat = 16.0
        public static let cornerRadius: CGFloat = 12.0
        public static let sectionPadding = EdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16)
    }
    
    public enum Animations {
        public static let buttonPress = Animation.interpolatingSpring(stiffness: 300, damping: 15)
        public static let cardHover = Animation.spring(response: 0.3, dampingFraction: 0.7)
        public static let standard = Animation.easeInOut(duration: 0.3)
        public static let quick = Animation.easeInOut(duration: 0.15)
    }
}

// Helper extension for Color to support hex values
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 