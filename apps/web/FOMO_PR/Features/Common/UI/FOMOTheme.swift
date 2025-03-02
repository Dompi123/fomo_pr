import SwiftUI

enum FOMOTheme {
    enum Colors {
        static let vividPink = Color(hex: 0xE91E63)
        static let oledBlack = Color(hex: 0x000000)
        static let cyanAccent = Color(hex: 0x00BCD4)
        
        static let background = oledBlack
        static let primary = vividPink
        static let secondary = cyanAccent
        static let surface = Color(hex: 0xF5F5F5)
        static let text = Color.white
        static let textSecondary = Color.gray
        
        static let buttonEnabled = primary
        static let buttonDisabled = Color.gray.opacity(0.5)
        
        static let success = Color(hex: 0x4CAF50)
        static let warning = Color(hex: 0xFFC107)
        static let error = Color(hex: 0xF44336)
        static let inactive = Color.gray
    }
    
    enum Typography {
        // Font Families
        private static let spaceGroteskBold = "SpaceGrotesk-Bold"
        private static let spaceGroteskMedium = "SpaceGrotesk-Medium"
        private static let sfPro = "SF Pro"
        private static let sfProDisplay = "SF Pro Display"
        
        // Text Styles
        struct TextStyle {
            let font: Font
            let lineSpacing: CGFloat
            let letterSpacing: CGFloat
            
            init(font: Font, lineSpacing: CGFloat = 1.2, letterSpacing: CGFloat = 0) {
                self.font = font
                self.lineSpacing = lineSpacing
                self.letterSpacing = letterSpacing
            }
        }
        
        // Legacy Styles (with improved typography)
        static let h1 = TextStyle(
            font: .custom(sfProDisplay, size: 32).weight(.bold),
            lineSpacing: 1.2,
            letterSpacing: -0.5
        )
        
        static let h2 = TextStyle(
            font: .custom(sfProDisplay, size: 24).weight(.semibold),
            lineSpacing: 1.2,
            letterSpacing: -0.3
        )
        
        static let body = TextStyle(
            font: .custom(sfPro, size: 16),
            lineSpacing: 1.4,
            letterSpacing: 0
        )
        
        static let caption = TextStyle(
            font: .custom(sfPro, size: 14),
            lineSpacing: 1.2,
            letterSpacing: 0.2
        )
        
        // Modern Styles
        static let titleLarge = TextStyle(
            font: .custom(spaceGroteskBold, size: 28),
            lineSpacing: 1.3,
            letterSpacing: -0.4
        )
        
        static let titleMedium = TextStyle(
            font: .custom(spaceGroteskBold, size: 22),
            lineSpacing: 1.3,
            letterSpacing: -0.3
        )
        
        static let titleSmall = TextStyle(
            font: .custom(spaceGroteskBold, size: 20),
            lineSpacing: 1.2,
            letterSpacing: -0.2
        )
        
        static let bodyLarge = TextStyle(
            font: .custom(spaceGroteskMedium, size: 17),
            lineSpacing: 1.4
        )
        
        static let bodyMedium = TextStyle(
            font: .custom(spaceGroteskMedium, size: 15),
            lineSpacing: 1.4
        )
        
        static let bodySmall = TextStyle(
            font: .custom(spaceGroteskMedium, size: 13),
            lineSpacing: 1.3
        )
    }
}

// MARK: - Color Hex Extension
extension Color {
    init(hex: Int) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}

// MARK: - Typography View Modifiers
struct FOMOTextStyle: ViewModifier {
    let style: FOMOTheme.Typography.TextStyle
    
    func body(content: Content) -> some View {
        content
            .font(style.font)
            .lineSpacing(style.lineSpacing)
            .tracking(style.letterSpacing)
    }
}

extension View {
    func fomoTextStyle(_ style: FOMOTheme.Typography.TextStyle) -> some View {
        modifier(FOMOTextStyle(style: style))
    }
}
