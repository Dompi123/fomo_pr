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
        
        // Additional colors used in venue views
        public static let textPrimary = Color.black
        public static let textTertiary = Color.gray.opacity(0.7)
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
        
        // Additional typography styles used in venue views
        public static let h1 = TextStyle(size: 24, weight: .bold)
        public static let h2 = TextStyle(size: 20, weight: .bold)
        public static let bodyBold = TextStyle(size: 16, weight: .bold)
        public static let caption = TextStyle(size: 12, weight: .regular)
        public static let button = TextStyle(size: 16, weight: .semibold)
        public static let titleMedium = TextStyle(size: 18, weight: .semibold)
        public static let titleSmall = TextStyle(size: 16, weight: .semibold)
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

// MARK: - TextStyle
public struct TextStyle {
    public let size: CGFloat
    public let weight: Font.Weight
    
    public init(size: CGFloat, weight: Font.Weight) {
        self.size = size
        self.weight = weight
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

// Add extension for Text to support TextStyle
public extension Text {
    func fomoTextStyle(_ style: TextStyle) -> Text {
        self.font(.system(size: style.size, weight: style.weight))
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