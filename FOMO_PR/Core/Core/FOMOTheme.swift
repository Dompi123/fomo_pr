import SwiftUI

public enum FOMOTheme {
    public enum Colors {
        public static let primary = Color("Primary", bundle: .module)
        public static let secondary = Color("Secondary", bundle: .module)
        public static let accent = Color("Accent", bundle: .module)
        public static let background = Color("Background", bundle: .module)
        public static let surface = Color("Surface", bundle: .module)
        public static let text = Color("Text", bundle: .module)
        public static let textPrimary = Color("TextPrimary", bundle: .module)
        public static let textSecondary = Color("TextSecondary", bundle: .module)
        public static let textTertiary = Color("TextTertiary", bundle: .module)
        public static let success = Color("Success", bundle: .module)
        public static let error = Color("Error", bundle: .module)
    }
    
    public enum Typography {
        public static let h1 = Font.system(.largeTitle, design: .rounded)
        public static let h2 = Font.system(.title, design: .rounded)
        public static let title1 = Font.system(.title2, design: .rounded)
        public static let titleMedium = Font.system(.title3, design: .rounded)
        public static let titleSmall = Font.system(.headline, design: .rounded)
        public static let body = Font.system(.body)
        public static let bodyBold = Font.system(.body).bold()
        public static let button = Font.system(.callout, design: .rounded)
        public static let caption = Font.system(.caption)
        public static let caption1 = Font.system(.caption)
    }
    
    public enum Spacing {
        public static let xxSmall: CGFloat = 4
        public static let xSmall: CGFloat = 8
        public static let small: CGFloat = 12
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 24
        public static let xLarge: CGFloat = 32
        public static let xxLarge: CGFloat = 40
    }
    
    public enum Radius {
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 16
    }
    
    public enum Shadow {
        public static let medium = Color.black.opacity(0.1)
    }
}

public enum FOMOAnimations {
    public static let smooth = Animation.easeInOut(duration: 0.3)
} 