import SwiftUI

public enum FOMOTheme {
    public enum Colors {
        // Primary Colors
        public static let primary = Color("PrimaryBrand")
        public static let secondary = Color("SecondaryBrand")
        public static let accent = Color("AccentBrand")
        
        // Semantic Colors
        public static let success = Color("Success")
        public static let warning = Color("Warning")
        public static let error = Color("Error")
        
        // Background Colors
        public static let background = Color("Background")
        public static let surface = Color("Surface")
        public static let surfaceElevated = Color("SurfaceElevated")
        
        // Text Colors
        public static let textPrimary = Color("TextPrimary")
        public static let textSecondary = Color("TextSecondary")
        public static let textTertiary = Color("TextTertiary")
    }
}

// MARK: - Color Extensions
extension Color {
    public static var brandPrimary: Color { FOMOTheme.Colors.primary }
    public static var brandSecondary: Color { FOMOTheme.Colors.secondary }
    public static var brandAccent: Color { FOMOTheme.Colors.accent }
} 