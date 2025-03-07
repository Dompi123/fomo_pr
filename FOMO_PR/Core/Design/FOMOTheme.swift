import SwiftUI

public enum FOMOTheme {
    // MARK: - Colors
    public enum Colors {
        public static let primary = Color("Primary", bundle: .module)
        public static let secondary = Color("Secondary", bundle: .main)
        public static let accent = Color("Accent", bundle: .main)
        public static let background = Color("Background", bundle: .main)
        public static let surface = Color("Surface", bundle: .module)
        public static let error = Color("Error", bundle: .module)
        public static let success = Color("Success", bundle: .module)
        public static let warning = Color("Warning", bundle: .main)
        public static let text = Color("Text", bundle: .module)
        public static let textSecondary = Color("TextSecondary", bundle: .module)
        
        // Fallback colors in case the named colors are not found
        public static let primaryFallback = Color(hex: "#4B0082") // Deep Purple
        public static let secondaryFallback = Color.black
        public static let accentFallback = Color.purple
        public static let backgroundFallback = Color(hex: "#1A1A1A") // Dark Background
        public static let surfaceFallback = Color(hex: "#2A2A2A")
        public static let errorFallback = Color.red
        public static let successFallback = Color.green
        public static let warningFallback = Color.yellow
        public static let textFallback = Color.white
        public static let textSecondaryFallback = Color.gray
    }
    
    // MARK: - Typography
    public enum Typography {
        public static let largeTitle = Font.custom("Poppins-Bold", size: 34)
        public static let title1 = Font.system(size: 24, weight: .bold)
        public static let title2 = Font.custom("Poppins-SemiBold", size: 22)
        public static let title3 = Font.custom("Poppins-SemiBold", size: 20)
        public static let headline = Font.custom("Poppins-SemiBold", size: 17)
        public static let body = Font.system(size: 16, weight: .regular)
        public static let callout = Font.custom("Poppins-Regular", size: 16)
        public static let subheadline = Font.custom("Poppins-Regular", size: 15)
        public static let footnote = Font.custom("Poppins-Regular", size: 13)
        public static let caption1 = Font.system(size: 12, weight: .medium)
        public static let caption2 = Font.custom("Poppins-Regular", size: 11)
        
        // Fallback fonts in case the custom fonts are not found
        public static let largeTitleFallback = Font.system(size: 34, weight: .bold, design: .rounded)
        public static let title1Fallback = Font.system(size: 26, weight: .bold, design: .default)
        public static let title2Fallback = Font.system(size: 22, weight: .bold, design: .default)
        public static let headlineFallback = Font.system(size: 17, weight: .semibold, design: .default)
        public static let subheadlineFallback = Font.system(size: 15, weight: .regular, design: .default)
        public static let bodyFallback = Font.system(size: 17, weight: .regular, design: .default)
        public static let headlineLarge = Font.system(size: 28, weight: .bold, design: .rounded)
        public static let headlineMedium = Font.system(size: 22, weight: .bold, design: .rounded)
        public static let headlineSmall = Font.system(size: 20, weight: .bold, design: .rounded)
        public static let bodyLarge = Font.system(size: 18)
        public static let bodyRegular = Font.system(size: 16)
        public static let bodySmall = Font.system(size: 14)
    }
    
    // MARK: - Spacing
    public enum Spacing {
        public static let xxxSmall: CGFloat = 2
        public static let xxSmall: CGFloat = 4
        public static let xSmall: CGFloat = 8
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 24
        public static let xLarge: CGFloat = 32
        public static let xxLarge: CGFloat = 40
        public static let xxxLarge: CGFloat = 48
    }
    
    // MARK: - Radius
    public enum Radius {
        public static let small: CGFloat = 4
        public static let medium: CGFloat = 8
        public static let large: CGFloat = 16
        public static let circle: CGFloat = .infinity
    }
    
    // MARK: - Shadow
    public enum Shadow {
        public static let light = Color.black.opacity(0.1)
        public static let medium = Color.black.opacity(0.1)
        public static let dark = Color.black.opacity(0.2)
    }
    
    // MARK: - Animation
    public enum Animation {
        public static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        public static let quick = SwiftUI.Animation.easeInOut(duration: 0.15)
        public static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)
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