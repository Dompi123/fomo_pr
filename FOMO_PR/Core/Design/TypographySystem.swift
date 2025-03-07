import SwiftUI

/// Comprehensive typography system for FOMO app
public enum TypographySystem {
    // MARK: - Font Names
    public enum FontFamily {
        public static let primary = "Poppins"
        public static let secondary = "SF Pro"
        public static let fallback = "System"
    }
    
    // MARK: - Font Weights
    public enum FontWeight {
        case regular
        case medium
        case semibold
        case bold
        
        var systemWeight: Font.Weight {
            switch self {
            case .regular:
                return .regular
            case .medium:
                return .medium
            case .semibold:
                return .semibold
            case .bold:
                return .bold
            }
        }
        
        var customWeightName: String {
            switch self {
            case .regular:
                return "Regular"
            case .medium:
                return "Medium"
            case .semibold:
                return "SemiBold"
            case .bold:
                return "Bold"
            }
        }
    }
    
    // MARK: - Font Sizes
    public enum FontSize {
        case xxxSmall
        case xxSmall
        case xSmall
        case small
        case medium
        case large
        case xLarge
        case xxLarge
        case xxxLarge
        case custom(CGFloat)
        
        var size: CGFloat {
            switch self {
            case .xxxSmall:
                return 10
            case .xxSmall:
                return 12
            case .xSmall:
                return 14
            case .small:
                return 16
            case .medium:
                return 18
            case .large:
                return 20
            case .xLarge:
                return 24
            case .xxLarge:
                return 28
            case .xxxLarge:
                return 32
            case .custom(let size):
                return size
            }
        }
    }
    
    // MARK: - Font Creation
    /// Creates a font with the specified family, weight, and size
    public static func font(family: String = FontFamily.primary, weight: FontWeight = .regular, size: FontSize = .medium) -> Font {
        let fontName = "\(family)-\(weight.customWeightName)"
        
        // First try custom font
        if let customFont = Font.custom(fontName, size: size.size) as? Font {
            return customFont
        }
        
        // Fallback to system font
        return Font.system(size: size.size, weight: weight.systemWeight)
    }
    
    // MARK: - Standard Text Styles
    public static let largeTitle = font(weight: .bold, size: .xxxLarge)
    public static let title1 = font(weight: .bold, size: .xxLarge)
    public static let title2 = font(weight: .semibold, size: .xLarge)
    public static let title3 = font(weight: .semibold, size: .large)
    public static let headline = font(weight: .semibold, size: .medium)
    public static let subheadline = font(weight: .medium, size: .small)
    public static let body = font(weight: .regular, size: .small)
    public static let bodyLarge = font(weight: .regular, size: .medium)
    public static let bodySmall = font(weight: .regular, size: .xSmall)
    public static let caption = font(weight: .regular, size: .xxSmall)
    public static let button = font(weight: .medium, size: .small)
    public static let buttonSmall = font(weight: .medium, size: .xSmall)
    public static let label = font(weight: .medium, size: .xSmall)
}

// MARK: - View Extensions for Typography
public extension View {
    /// Apply one of the standard text styles
    func typography(_ style: Font) -> some View {
        self.font(style)
    }
    
    // MARK: - Semantic Typography Modifiers
    
    /// Large title style for main headlines
    func largeTitle() -> some View {
        self.font(TypographySystem.largeTitle)
    }
    
    /// Title 1 style for important section headers
    func title1() -> some View {
        self.font(TypographySystem.title1)
    }
    
    /// Title 2 style for section headers
    func title2() -> some View {
        self.font(TypographySystem.title2)
    }
    
    /// Title 3 style for subsection headers
    func title3() -> some View {
        self.font(TypographySystem.title3)
    }
    
    /// Headline style for emphasized text
    func headline() -> some View {
        self.font(TypographySystem.headline)
    }
    
    /// Subheadline style for descriptive headers
    func subheadline() -> some View {
        self.font(TypographySystem.subheadline)
    }
    
    /// Body style for regular text content
    func body() -> some View {
        self.font(TypographySystem.body)
    }
    
    /// Large body style for emphasized paragraphs
    func bodyLarge() -> some View {
        self.font(TypographySystem.bodyLarge)
    }
    
    /// Small body style for less important text
    func bodySmall() -> some View {
        self.font(TypographySystem.bodySmall)
    }
    
    /// Caption style for annotations and footnotes
    func caption() -> some View {
        self.font(TypographySystem.caption)
    }
    
    /// Button style for clickable elements
    func buttonText() -> some View {
        self.font(TypographySystem.button)
    }
    
    /// Small button style for compact buttons
    func buttonTextSmall() -> some View {
        self.font(TypographySystem.buttonSmall)
    }
    
    /// Label style for form labels and metadata
    func label() -> some View {
        self.font(TypographySystem.label)
    }
    
    // MARK: - Combined Typography + Color Modifiers
    
    /// Apply headline style with primary text color
    func headlinePrimary() -> some View {
        self.font(TypographySystem.headline)
            .foregroundColor(ThemeManager.shared.activeTheme.textPrimary)
    }
    
    /// Apply body style with secondary text color
    func bodySecondary() -> some View {
        self.font(TypographySystem.body)
            .foregroundColor(ThemeManager.shared.activeTheme.textSecondary)
    }
    
    /// Apply caption style with tertiary text color
    func captionTertiary() -> some View {
        self.font(TypographySystem.caption)
            .foregroundColor(ThemeManager.shared.activeTheme.textTertiary)
    }
}

// MARK: - Font Registration
public extension TypographySystem {
    /// Register custom fonts with the system
    static func registerFonts() {
        // This would load font files bundled with the app
        // Example implementation (would need actual font files):
        /*
        let fontNames = ["Poppins-Regular", "Poppins-Medium", "Poppins-SemiBold", "Poppins-Bold"]
        
        for fontName in fontNames {
            guard let fontURL = Bundle.main.url(forResource: fontName, withExtension: "ttf"),
                  let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
                  let font = CGFont(fontDataProvider) else {
                continue
            }
            
            var error: Unmanaged<CFError>?
            if !CTFontManagerRegisterGraphicsFont(font, &error) {
                print("Error registering font: \(fontName)")
            }
        }
        */
    }
}

// MARK: - Preview
struct TypographySystem_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                Group {
                    Text("Large Title").largeTitle()
                    Text("Title 1").title1()
                    Text("Title 2").title2()
                    Text("Title 3").title3()
                    Text("Headline").headline()
                    Text("Subheadline").subheadline()
                }
                
                Divider().padding(.vertical)
                
                Group {
                    Text("Body").body()
                    Text("Body Large").bodyLarge()
                    Text("Body Small").bodySmall()
                    Text("Caption").caption()
                    Text("Button").buttonText()
                    Text("Small Button").buttonTextSmall()
                    Text("Label").label()
                }
                
                Divider().padding(.vertical)
                
                Group {
                    Text("Headline Primary").headlinePrimary()
                    Text("Body Secondary").bodySecondary()
                    Text("Caption Tertiary").captionTertiary()
                }
            }
            .padding()
        }
        .withTheme()
    }
} 