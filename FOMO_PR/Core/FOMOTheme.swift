import SwiftUI

/**
 * FOMOTheme adapter - redirects legacy theme references to the new design system
 * This ensures backward compatibility while we transition to the new structure
 */
public enum FOMOTheme {
    // MARK: - Colors (Legacy API)
    
    @available(*, deprecated, message: "Use FOMOTheme.Colors.primary instead")
    public static var primaryColor: Color { return Colors.primary }
    
    @available(*, deprecated, message: "Use FOMOTheme.Colors.background instead")
    public static var backgroundColor: Color { return Colors.background }
    
    @available(*, deprecated, message: "Use FOMOTheme.Colors.text instead")
    public static var textColor: Color { return Colors.text }
    
    @available(*, deprecated, message: "Use FOMOTheme.Colors.textSecondary instead")
    public static var lightTextColor: Color { return Colors.textSecondary }
    
    @available(*, deprecated, message: "Use FOMOTheme.Colors.success instead")
    public static var successColor: Color { return Colors.success }
    
    @available(*, deprecated, message: "Use FOMOTheme.Colors.error instead")
    public static var errorColor: Color { return Colors.error }
    
    // MARK: - Typography (Legacy API)
    
    @available(*, deprecated, message: "Use FOMOTheme.Typography.title1 instead")
    public static var titleFont: Font { return Typography.title1 }
    
    @available(*, deprecated, message: "Use FOMOTheme.Typography.headline instead")
    public static var subtitleFont: Font { return Typography.headline }
    
    @available(*, deprecated, message: "Use FOMOTheme.Typography.body instead")
    public static var bodyFont: Font { return Typography.body }
    
    @available(*, deprecated, message: "Use FOMOTheme.Typography.subheadline instead")
    public static var smallFont: Font { return Typography.subheadline }
    
    // MARK: - Layout (Legacy API)
    
    @available(*, deprecated, message: "Use FOMOTheme.Layout.cornerRadiusRegular instead")
    public static var cornerRadius: CGFloat { return Layout.cornerRadiusRegular }
    
    @available(*, deprecated, message: "Use FOMOTheme.Layout.paddingMedium instead")
    public static var padding: CGFloat { return Layout.paddingMedium }
    
    @available(*, deprecated, message: "Use FOMOTheme.Layout.paddingSmall instead")
    public static var smallPadding: CGFloat { return Layout.paddingSmall }
    
    // MARK: - Modern Design System
    
    public enum Colors {
        // Forward compatible properties that redirect to the new design system
        public static var primary: Color { return Core.Design.FOMOTheme.Colors.primary }
        public static var primaryVariant: Color { return Core.Design.FOMOTheme.Colors.primaryVariant }
        public static var secondary: Color { return Core.Design.FOMOTheme.Colors.secondary }
        public static var background: Color { return Core.Design.FOMOTheme.Colors.background }
        public static var surface: Color { return Core.Design.FOMOTheme.Colors.surface }
        public static var surfaceVariant: Color { return Core.Design.FOMOTheme.Colors.surfaceVariant }
        public static var accent: Color { return Core.Design.FOMOTheme.Colors.accent }
        public static var text: Color { return Core.Design.FOMOTheme.Colors.text }
        public static var textSecondary: Color { return Core.Design.FOMOTheme.Colors.textSecondary }
        public static var success: Color { return Core.Design.FOMOTheme.Colors.success }
        public static var warning: Color { return Core.Design.FOMOTheme.Colors.warning }
        public static var error: Color { return Core.Design.FOMOTheme.Colors.error }
        
        // Fallbacks in case the new system isn't available
        public static let primaryFallback = Color(hex: "#9C30FF")
        public static let secondaryFallback = Color(hex: "#1DB954")
        public static let accentFallback = Color(hex: "#BB86FC")
        public static let backgroundFallback = Color(hex: "#121212")
        public static let surfaceFallback = Color(hex: "#282828")
        public static let errorFallback = Color(hex: "#E61E32")
        public static let successFallback = Color(hex: "#1DB954")
        public static let warningFallback = Color(hex: "#FFBD00")
        public static let textFallback = Color.white
        public static let textSecondaryFallback = Color(hex: "#B3B3B3")
    }
    
    public enum Typography {
        // Forward compatible properties that redirect to the new design system
        public static var display: Font { return .system(size: Core.Design.FOMOTheme.Typography.fontSizeDisplay, weight: .bold) }
        public static var title1: Font { return .system(size: Core.Design.FOMOTheme.Typography.fontSizeTitle1, weight: .bold) }
        public static var title2: Font { return .system(size: Core.Design.FOMOTheme.Typography.fontSizeTitle2, weight: .bold) }
        public static var headline: Font { return .system(size: Core.Design.FOMOTheme.Typography.fontSizeHeadline, weight: .semibold) }
        public static var subheadline: Font { return .system(size: Core.Design.FOMOTheme.Typography.fontSizeSubheadline, weight: .medium) }
        public static var body: Font { return .system(size: Core.Design.FOMOTheme.Typography.fontSizeBody, weight: .regular) }
        public static var bodyLarge: Font { return .system(size: Core.Design.FOMOTheme.Typography.fontSizeBodyLarge, weight: .regular) }
        public static var caption: Font { return .system(size: Core.Design.FOMOTheme.Typography.fontSizeCaption, weight: .regular) }
        public static var button: Font { return .system(size: Core.Design.FOMOTheme.Typography.fontSizeButton, weight: .semibold) }
        
        // Mapping function to get new text style from legacy fonts
        public static func getTextStyleForLegacyFont(_ font: Font) -> FOMOText.TextStyle {
            // This is approximate and should be refined based on actual usage
            if font == titleFont {
                return .title1
            } else if font == subtitleFont {
                return .headline
            } else if font == bodyFont {
                return .body
            } else if font == smallFont {
                return .subheadline
            } else {
                return .body // Default
            }
        }
    }
    
    public enum Layout {
        // Corner radius
        public static var cornerRadiusSmall: CGFloat { return Core.Design.FOMOTheme.Layout.cornerRadiusSmall }
        public static var cornerRadiusRegular: CGFloat { return Core.Design.FOMOTheme.Layout.cornerRadiusRegular }
        public static var cornerRadiusMedium: CGFloat { return Core.Design.FOMOTheme.Layout.cornerRadiusLarge }
        public static var cornerRadiusLarge: CGFloat { return Core.Design.FOMOTheme.Layout.cornerRadiusXL }
        public static var cornerRadiusExtraLarge: CGFloat { return 32 } // Not in new system
        
        // Padding
        public static var paddingTiny: CGFloat { return Core.Design.FOMOTheme.Layout.spacingXS }
        public static var paddingSmall: CGFloat { return Core.Design.FOMOTheme.Layout.spacingS }
        public static var paddingMedium: CGFloat { return Core.Design.FOMOTheme.Layout.spacingM }
        public static var paddingLarge: CGFloat { return Core.Design.FOMOTheme.Layout.spacingL }
        public static var paddingExtraLarge: CGFloat { return Core.Design.FOMOTheme.Layout.spacingXL }
        
        // Spacing
        public static var spacingTiny: CGFloat { return Core.Design.FOMOTheme.Layout.spacingXS }
        public static var spacingSmall: CGFloat { return Core.Design.FOMOTheme.Layout.spacingS }
        public static var spacingMedium: CGFloat { return Core.Design.FOMOTheme.Layout.spacingM }
        public static var spacingLarge: CGFloat { return Core.Design.FOMOTheme.Layout.spacingL }
        public static var spacingExtraLarge: CGFloat { return Core.Design.FOMOTheme.Layout.spacingXL }
    }
    
    public enum Shadows {
        public static var small: Shadow { return Core.Design.FOMOTheme.Layout.shadowSmall }
        public static var medium: Shadow { return Core.Design.FOMOTheme.Layout.shadowMedium }
        public static var large: Shadow { return Core.Design.FOMOTheme.Layout.shadowLarge }
        
        // Legacy shadow color definitions
        @available(*, deprecated, message: "Use FOMOTheme.Shadows.small instead")
        public static let light = Color.black.opacity(0.1)
        
        @available(*, deprecated, message: "Use FOMOTheme.Shadows.medium instead")
        public static let medium = Color.black.opacity(0.15)
        
        @available(*, deprecated, message: "Use FOMOTheme.Shadows.large instead")
        public static let dark = Color.black.opacity(0.2)
    }
    
    // MARK: - Animation
    
    public enum Animation {
        @available(*, deprecated, message: "Use FOMOTheme.Animations.defaultEasing instead")
        public static let standard = SwiftUI.Animation.easeInOut(duration: 0.3)
        
        @available(*, deprecated, message: "Use FOMOTheme.Animations.defaultEasing with shorter duration instead")
        public static let quick = SwiftUI.Animation.easeInOut(duration: 0.15)
        
        @available(*, deprecated, message: "Use FOMOTheme.Animations.defaultSpring instead")
        public static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.6)
    }
    
    // MARK: - Migration Utilities
    
    /// Convenience namespace for migration utilities
    public enum Migration {
        /// Maps a legacy color to the new color system
        public static func mapColor(_ legacyColor: Color) -> Color {
            if legacyColor == primaryColor { return Colors.primary }
            if legacyColor == backgroundColor { return Colors.background }
            if legacyColor == textColor { return Colors.text }
            if legacyColor == lightTextColor { return Colors.textSecondary }
            if legacyColor == successColor { return Colors.success }
            if legacyColor == errorColor { return Colors.error }
            return legacyColor // If no match, return original
        }
        
        /// Gets the appropriate button style based on legacy appearance
        public static func getButtonStyle(
            backgroundColor: Color,
            textColor: Color,
            hasBorder: Bool
        ) -> FOMOButton.ButtonStyle {
            if backgroundColor == Colors.primary {
                return .primary
            } else if backgroundColor == Colors.secondary {
                return .secondary
            } else if backgroundColor.opacity == 0 && hasBorder {
                return .outline
            } else if backgroundColor.opacity == 0 {
                return .ghost
            } else {
                return .primary // Default
            }
        }
        
        /// Gets the appropriate card style based on legacy appearance
        public static func getCardStyle(
            backgroundColor: Color,
            hasBorder: Bool,
            elevation: Int = 1
        ) -> FOMOCard<EmptyView>.CardStyle {
            if backgroundColor == Colors.surface {
                return elevation > 1 ? .premium : .primary
            } else if backgroundColor.opacity < 1 {
                return .secondary
            } else if hasBorder {
                return .minimal
            } else {
                return .primary // Default
            }
        }
        
        /// Gets the appropriate tag style based on legacy appearance
        public static func getTagStyle(
            backgroundColor: Color,
            textColor: Color,
            hasBorder: Bool
        ) -> FOMOTag.TagStyle {
            if backgroundColor == Colors.primary.opacity(0.2) {
                return .primary
            } else if backgroundColor == Colors.success.opacity(0.2) {
                return .success
            } else if backgroundColor == Colors.warning.opacity(0.2) {
                return .warning
            } else if backgroundColor == Colors.error.opacity(0.2) {
                return .error
            } else if backgroundColor.opacity == 0 && hasBorder {
                return .outline
            } else if backgroundColor == Colors.surface {
                return .secondary
            } else {
                return .primary // Default
            }
        }
    }
}

// Shadow structure compatibility
public typealias Shadow = Core.Design.Shadow

// Extension to create colors from hex values (for backward compatibility)
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

// MARK: - Animation View Modifiers (Legacy support)

// Scaling button press effect
struct PressEffectModifier: ViewModifier {
    @State private var isPressed = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(Core.Design.FOMOTheme.Animations.defaultSpring, value: isPressed)
            .onTapGesture {
                withAnimation {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                    }
                }
            }
    }
}

// Card hover effect
struct CardHoverEffectModifier: ViewModifier {
    @State private var isHovering = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isHovering ? 1.03 : 1.0)
            .shadow(
                color: isHovering ? FOMOTheme.Colors.primary.opacity(0.2) : Color.black.opacity(0.1),
                radius: isHovering ? 8 : 4,
                x: 0,
                y: isHovering ? 4 : 2
            )
            .animation(Core.Design.FOMOTheme.Animations.defaultSpring, value: isHovering)
            .onHover { hovering in
                isHovering = hovering
            }
    }
}

// Staggered appearance for list items
struct StaggeredAppearanceModifier: ViewModifier {
    let index: Int
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        content
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 20)
            .onAppear {
                withAnimation(Animation.easeOut(duration: 0.3).delay(Double(index) * 0.05)) {
                    hasAppeared = true
                }
            }
    }
}

// Pop-in effect for elements that need attention
struct PopInEffectModifier: ViewModifier {
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(hasAppeared ? 1.0 : 0.6)
            .opacity(hasAppeared ? 1.0 : 0.0)
            .onAppear {
                withAnimation(Core.Design.FOMOTheme.Animations.defaultSpring) {
                    hasAppeared = true
                }
            }
    }
}

// MARK: - View Extension for Animation Modifiers (Legacy Support)

extension View {
    // MARK: - Legacy Support
    
    @available(*, deprecated, message: "Use FOMOButton with isInteractive=true instead")
    func pressEffect() -> some View {
        modifier(PressEffectModifier())
    }
    
    @available(*, deprecated, message: "Use FOMOCard with isInteractive=true instead")
    func cardHoverEffect() -> some View {
        modifier(CardHoverEffectModifier())
    }
    
    @available(*, deprecated, message: "Custom animation will be provided in the animation system")
    func staggeredAppearance(index: Int) -> some View {
        modifier(StaggeredAppearanceModifier(index: index))
    }
    
    @available(*, deprecated, message: "Custom animation will be provided in the animation system")
    func popInEffect() -> some View {
        modifier(PopInEffectModifier())
    }
    
    // MARK: - Migration Helper Extensions
    
    /// Converts legacy styling to FOMOText
    func migrateToFOMOText(
        font: Font,
        color: Color = FOMOTheme.Colors.text,
        alignment: TextAlignment = .leading
    ) -> some View {
        let textStyle = FOMOTheme.Typography.getTextStyleForLegacyFont(font)
        return self.font(nil)
            .foregroundColor(nil)
            .fomoTextStyle(textStyle: textStyle, color: color, alignment: alignment)
    }
    
    /// Helper for applying FOMO text styling to any text view
    func fomoTextStyle(
        textStyle: FOMOText.TextStyle,
        color: Color? = nil,
        alignment: TextAlignment = .leading
    ) -> some View {
        self
            .font(textStyle.font)
            .fontWeight(textStyle.weight)
            .foregroundColor(color ?? textStyle.color)
            .multilineTextAlignment(alignment)
            .lineSpacing(textStyle.lineSpacing)
    }
    
    /// Adds a consistent shadow using new FOMOTheme shadow
    @available(*, deprecated, message: "Use withShadow from the new design system")
    func themeShadow(_ shadowLevel: String) -> some View {
        switch shadowLevel {
        case "light":
            return self.withShadow(FOMOTheme.Shadows.small)
        case "medium":
            return self.withShadow(FOMOTheme.Shadows.medium)
        case "dark":
            return self.withShadow(FOMOTheme.Shadows.large)
        default:
            return self.withShadow(FOMOTheme.Shadows.small)
        }
    }
    
    /// Apply standard theme corner radius (Legacy support)
    @available(*, deprecated, message: "Use cornerRadius with values from FOMOTheme.Layout")
    func themeCornerRadius(_ radiusName: String = "medium") -> some View {
        switch radiusName {
        case "small":
            return self.cornerRadius(FOMOTheme.Layout.cornerRadiusSmall)
        case "medium":
            return self.cornerRadius(FOMOTheme.Layout.cornerRadiusRegular)
        case "large":
            return self.cornerRadius(FOMOTheme.Layout.cornerRadiusMedium)
        case "extraLarge", "xl":
            return self.cornerRadius(FOMOTheme.Layout.cornerRadiusLarge)
        default:
            return self.cornerRadius(FOMOTheme.Layout.cornerRadiusRegular)
        }
    }
}

// MARK: - Preview

struct FOMOTheme_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: FOMOTheme.Layout.spacingMedium) {
            Text("Title")
                .font(FOMOTheme.Typography.title1)
                .foregroundColor(FOMOTheme.Colors.text)
            
            Text("Body")
                .font(FOMOTheme.Typography.body)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
        }
        .padding()
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Layout.cornerRadiusRegular)
        .withShadow(FOMOTheme.Shadows.medium)
    }
} 