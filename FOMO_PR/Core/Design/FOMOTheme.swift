import SwiftUI

/**
 * FOMOTheme: Central theme configuration for the FOMO app
 * This struct contains all the design tokens for colors, typography, spacing, etc.
 */
public struct FOMOTheme {
    // MARK: - Colors
    
    public struct Colors {
        // Main colors
        public static let primary = Color(hex: "#9C30FF")       // Primary purple
        public static let primaryVariant = Color(hex: "#7917D1") // Darker purple
        public static let secondary = Color(hex: "#1DB954")     // Spotify green
        public static let accent = Color(hex: "#BB86FC")        // Lighter purple
        
        // Background colors
        public static let background = Color(hex: "#121212")    // Main background (very dark)
        public static let surface = Color(hex: "#282828")       // Card/surface background
        public static let surfaceVariant = Color(hex: "#3E3E3E") // Lighter surface
        
        // Text colors
        public static let text = Color.white                     // Primary text
        public static let textSecondary = Color(hex: "#B3B3B3") // Secondary text
        
        // Status colors
        public static let success = Color(hex: "#1DB954")       // Success/positive (green)
        public static let warning = Color(hex: "#FFBD00")       // Warning (yellow)
        public static let error = Color(hex: "#E61E32")         // Error/negative (red)
        
        // Gradient definitions
        public static let primaryGradient = LinearGradient(
            gradient: Gradient(colors: [primary, primaryVariant]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        
        public static let premiumGradient = LinearGradient(
            gradient: Gradient(colors: [Color(hex: "#B07CFF"), Color(hex: "#5D26C1")]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    // MARK: - Typography
    
    public struct Typography {
        // Font sizes
        public static let fontSizeDisplay: CGFloat = 34
        public static let fontSizeTitle1: CGFloat = 28
        public static let fontSizeTitle2: CGFloat = 22
        public static let fontSizeHeadline: CGFloat = 17
        public static let fontSizeSubheadline: CGFloat = 15
        public static let fontSizeBody: CGFloat = 17
        public static let fontSizeBodyLarge: CGFloat = 19
        public static let fontSizeCaption: CGFloat = 13
        public static let fontSizeButton: CGFloat = 16
        
        // Font weights
        public static let fontWeightRegular = Font.Weight.regular
        public static let fontWeightMedium = Font.Weight.medium
        public static let fontWeightSemibold = Font.Weight.semibold
        public static let fontWeightBold = Font.Weight.bold
        
        // Line heights
        public static let lineHeightDefault: CGFloat = 1.2
        public static let lineHeightRelaxed: CGFloat = 1.5
        
        // Letter spacing
        public static let letterSpacingTight: CGFloat = -0.5
        public static let letterSpacingNormal: CGFloat = 0
        public static let letterSpacingWide: CGFloat = 0.5
    }
    
    // MARK: - Layout
    
    public struct Layout {
        // Spacing
        public static let spacingXS: CGFloat = 4
        public static let spacingS: CGFloat = 8
        public static let spacingM: CGFloat = 16
        public static let spacingL: CGFloat = 24
        public static let spacingXL: CGFloat = 32
        public static let spacingXXL: CGFloat = 48
        
        // Corner radius
        public static let cornerRadiusSmall: CGFloat = 8
        public static let cornerRadiusRegular: CGFloat = 12
        public static let cornerRadiusLarge: CGFloat = 16
        public static let cornerRadiusXL: CGFloat = 24
        
        // Shadows
        public static let shadowSmall: Shadow = Shadow(
            color: Color.black.opacity(0.15),
            radius: 4,
            x: 0,
            y: 2
        )
        
        public static let shadowMedium: Shadow = Shadow(
            color: Color.black.opacity(0.2),
            radius: 8,
            x: 0,
            y: 4
        )
        
        public static let shadowLarge: Shadow = Shadow(
            color: Color.black.opacity(0.25),
            radius: 16,
            x: 0,
            y: 8
        )
        
        // Button sizes
        public static let buttonHeightSmall: CGFloat = 36
        public static let buttonHeightMedium: CGFloat = 44
        public static let buttonHeightLarge: CGFloat = 56
        
        // Tag sizes
        public static let tagHeightSmall: CGFloat = 24
        public static let tagHeightMedium: CGFloat = 32
        public static let tagHeightLarge: CGFloat = 40
    }
    
    // MARK: - Animations
    
    public struct Animations {
        public static let defaultDuration: Double = 0.25
        public static let slowDuration: Double = 0.4
        public static let defaultSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
        public static let defaultEasing = Animation.easeInOut(duration: defaultDuration)
        public static let defaultDelay: Double = 0.05
    }
}

// MARK: - Shadow

public struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

// MARK: - Color Extension

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
            (a, r, g, b) = (255, 0, 0, 0)
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

// MARK: - View Extension for Shadow Application

extension View {
    func withShadow(_ shadow: Shadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }
}

// MARK: - View Extensions
public extension View {
    func fomoBackground(_ color: Color = FOMOTheme.Colors.background) -> some View {
        self.background(color)
    }
    
    func fomoTextStyle(_ font: Font) -> some View {
        self.font(font)
    }
    
    func fomoShadow(color: Color = FOMOTheme.Shadow.medium, radius: CGFloat = 4, x: CGFloat = 0, y: CGFloat = 2) -> some View {
        self.shadow(color: color, radius: radius, x: x, y: y)
    }
    
    func fomoCornerRadius(_ radius: CGFloat = FOMOTheme.Radius.medium) -> some View {
        self.cornerRadius(radius)
    }
}

// MARK: - Preview
struct FOMOTheme_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: FOMOTheme.Spacing.medium) {
            Text("Title")
                .font(FOMOTheme.Typography.title1)
                .foregroundColor(FOMOTheme.Colors.text)
            
            Text("Body")
                .font(FOMOTheme.Typography.body)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
        }
        .padding()
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Radius.medium)
        .shadow(color: FOMOTheme.Shadow.medium, radius: 4)
    }
} 