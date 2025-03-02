import SwiftUI

extension FOMOTheme {
    public enum Typography {
        public static let h1 = Font.system(size: 32, weight: .bold)
        public static let h2 = Font.system(size: 24, weight: .bold)
        public static let h3 = Font.system(size: 20, weight: .semibold)
        public static let titleLarge = Font.system(size: 22, weight: .semibold)
        public static let titleMedium = Font.system(size: 18, weight: .semibold)
        public static let titleSmall = Font.system(size: 16, weight: .semibold)
        public static let body = Font.system(size: 16, weight: .regular)
        public static let bodySmall = Font.system(size: 14, weight: .regular)
        public static let caption = Font.system(size: 12, weight: .regular)
        public static let button = Font.system(size: 16, weight: .medium)
    }
}

extension View {
    public func fomoTextStyle(_ font: Font) -> some View {
        self.font(font)
    }
} 