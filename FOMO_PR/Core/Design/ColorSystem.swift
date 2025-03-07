import SwiftUI

/// Comprehensive color system for FOMO app
public enum ColorSystem {
    // MARK: - Color Palette
    
    /// Primary brand colors
    public enum Brand {
        /// Main brand color
        public static let primary = Color("PrimaryBrand", bundle: .main)
        
        /// Secondary brand color for accents
        public static let secondary = Color("SecondaryBrand", bundle: .main)
        
        /// Third level brand color
        public static let tertiary = Color("TertiaryBrand", bundle: .main)
    }
    
    /// Semantic status colors
    public enum Status {
        /// Success state color (green)
        public static let success = Color("Success", bundle: .main)
        
        /// Warning state color (yellow/orange)
        public static let warning = Color("Warning", bundle: .main)
        
        /// Error state color (red)
        public static let error = Color("Error", bundle: .main)
        
        /// Information state color (blue)
        public static let info = Color("Info", bundle: .main)
    }
    
    /// Background colors
    public enum Background {
        /// Main background color
        public static let primary = Color("BackgroundPrimary", bundle: .main)
        
        /// Secondary background for cards
        public static let secondary = Color("BackgroundSecondary", bundle: .main)
        
        /// Tertiary background for UI elements
        public static let tertiary = Color("BackgroundTertiary", bundle: .main)
        
        /// Elevated surfaces
        public static let elevated = Color("BackgroundElevated", bundle: .main)
    }
    
    /// Text colors
    public enum Text {
        /// Primary text color
        public static let primary = Color("TextPrimary", bundle: .main)
        
        /// Secondary text color
        public static let secondary = Color("TextSecondary", bundle: .main)
        
        /// Tertiary text color
        public static let tertiary = Color("TextTertiary", bundle: .main)
        
        /// Inverted text color (for dark backgrounds)
        public static let inverted = Color("TextInverted", bundle: .main)
    }
    
    /// Border colors
    public enum Border {
        /// Standard border color
        public static let standard = Color("BorderStandard", bundle: .main)
        
        /// Subtle border color
        public static let subtle = Color("BorderSubtle", bundle: .main)
        
        /// Focus/active border color
        public static let focus = Color("BorderFocus", bundle: .main)
    }
    
    // MARK: - Color Generation
    
    /// Creates a color with opacity
    public static func withOpacity(_ color: Color, opacity: Double) -> Color {
        color.opacity(opacity)
    }
    
    /// Creates a gradient from two colors
    public static func gradient(from color1: Color, to color2: Color) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [color1, color2]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Creates a brand gradient
    public static var brandGradient: LinearGradient {
        gradient(from: Brand.primary, to: Brand.secondary)
    }
}

// MARK: - View Extensions for Colors
public extension View {
    // MARK: - Foreground Color Modifiers
    
    /// Apply primary text color
    func foregroundPrimary() -> some View {
        self.foregroundColor(ThemeManager.shared.activeTheme.textPrimary)
    }
    
    /// Apply secondary text color
    func foregroundSecondary() -> some View {
        self.foregroundColor(ThemeManager.shared.activeTheme.textSecondary)
    }
    
    /// Apply tertiary text color
    func foregroundTertiary() -> some View {
        self.foregroundColor(ThemeManager.shared.activeTheme.textTertiary)
    }
    
    /// Apply brand primary color as foreground
    func foregroundBrand() -> some View {
        self.foregroundColor(ThemeManager.shared.activeTheme.primary)
    }
    
    /// Apply success color as foreground
    func foregroundSuccess() -> some View {
        self.foregroundColor(ColorSystem.Status.success)
    }
    
    /// Apply warning color as foreground
    func foregroundWarning() -> some View {
        self.foregroundColor(ColorSystem.Status.warning)
    }
    
    /// Apply error color as foreground
    func foregroundError() -> some View {
        self.foregroundColor(ColorSystem.Status.error)
    }
    
    // MARK: - Background Color Modifiers
    
    /// Apply primary background color
    func backgroundPrimary() -> some View {
        self.background(ThemeManager.shared.activeTheme.background)
    }
    
    /// Apply surface background color
    func backgroundSurface() -> some View {
        self.background(ThemeManager.shared.activeTheme.surface)
    }
    
    /// Apply elevated surface background color
    func backgroundElevated() -> some View {
        self.background(ThemeManager.shared.activeTheme.surfaceElevated)
    }
    
    /// Apply brand primary color as background
    func backgroundBrand() -> some View {
        self.background(ThemeManager.shared.activeTheme.primary)
    }
    
    /// Apply success color as background
    func backgroundSuccess() -> some View {
        self.background(ColorSystem.Status.success)
    }
    
    /// Apply warning color as background
    func backgroundWarning() -> some View {
        self.background(ColorSystem.Status.warning)
    }
    
    /// Apply error color as background
    func backgroundError() -> some View {
        self.background(ColorSystem.Status.error)
    }
    
    // MARK: - Border Color Modifiers
    
    /// Apply standard border
    func standardBorder(width: CGFloat = 1) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: FOMOTheme.Radius.medium)
                .stroke(ColorSystem.Border.standard, lineWidth: width)
        )
    }
    
    /// Apply focus border
    func focusBorder(width: CGFloat = 2) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: FOMOTheme.Radius.medium)
                .stroke(ColorSystem.Border.focus, lineWidth: width)
        )
    }
}

// MARK: - Preview
struct ColorSystem_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Brand Colors
                Group {
                    Text("Brand Colors").title3()
                    
                    HStack {
                        ColorSwatch(color: ColorSystem.Brand.primary, name: "Primary")
                        ColorSwatch(color: ColorSystem.Brand.secondary, name: "Secondary")
                        ColorSwatch(color: ColorSystem.Brand.tertiary, name: "Tertiary")
                    }
                }
                
                // Status Colors
                Group {
                    Text("Status Colors").title3()
                    
                    HStack {
                        ColorSwatch(color: ColorSystem.Status.success, name: "Success")
                        ColorSwatch(color: ColorSystem.Status.warning, name: "Warning")
                        ColorSwatch(color: ColorSystem.Status.error, name: "Error")
                        ColorSwatch(color: ColorSystem.Status.info, name: "Info")
                    }
                }
                
                // Background Colors
                Group {
                    Text("Background Colors").title3()
                    
                    HStack {
                        ColorSwatch(color: ColorSystem.Background.primary, name: "Primary")
                        ColorSwatch(color: ColorSystem.Background.secondary, name: "Secondary")
                        ColorSwatch(color: ColorSystem.Background.tertiary, name: "Tertiary")
                        ColorSwatch(color: ColorSystem.Background.elevated, name: "Elevated")
                    }
                }
                
                // Text Colors
                Group {
                    Text("Text Colors").title3()
                    
                    HStack {
                        ColorSwatch(color: ColorSystem.Text.primary, name: "Primary")
                        ColorSwatch(color: ColorSystem.Text.secondary, name: "Secondary")
                        ColorSwatch(color: ColorSystem.Text.tertiary, name: "Tertiary")
                        ColorSwatch(color: ColorSystem.Text.inverted, name: "Inverted")
                    }
                }
                
                // Border Colors
                Group {
                    Text("Border Colors").title3()
                    
                    HStack {
                        ColorSwatch(color: ColorSystem.Border.standard, name: "Standard")
                        ColorSwatch(color: ColorSystem.Border.subtle, name: "Subtle")
                        ColorSwatch(color: ColorSystem.Border.focus, name: "Focus")
                    }
                }
                
                // Gradients
                Group {
                    Text("Gradients").title3()
                    
                    Rectangle()
                        .fill(ColorSystem.brandGradient)
                        .frame(height: 60)
                        .cornerRadius(FOMOTheme.Radius.medium)
                        .overlay(
                            Text("Brand Gradient")
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        )
                }
                
                // Examples of modifiers
                Group {
                    Text("Modifier Examples").title3()
                    
                    Text("Foreground Primary").foregroundPrimary()
                    Text("Foreground Secondary").foregroundSecondary()
                    Text("Foreground Brand").foregroundBrand()
                    
                    Text("Standard Border")
                        .padding()
                        .standardBorder()
                    
                    Text("Focus Border")
                        .padding()
                        .focusBorder()
                }
            }
            .padding()
        }
        .withTheme()
    }
}

/// Helper view for the color preview
struct ColorSwatch: View {
    let color: Color
    let name: String
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(color)
                .frame(height: 60)
                .cornerRadius(FOMOTheme.Radius.small)
            
            Text(name)
                .font(.system(size: 12))
        }
    }
} 