import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - Theme
public enum FOMOTheme {
    public enum Colors {
        public static let primary = Color.blue
        public static let secondary = Color.purple
        
        #if canImport(UIKit)
        public static let background = Color(UIColor.systemBackground)
        public static let surface = Color(UIColor.secondarySystemBackground)
        public static let text = Color(UIColor.label)
        public static let textSecondary = Color(UIColor.secondaryLabel)
        #else
        public static let background = Color.white
        public static let surface = Color.gray.opacity(0.1)
        public static let text = Color.black
        public static let textSecondary = Color.gray
        #endif
        
        public static let success = Color.green
        public static let error = Color.red
    }
    
    public enum Typography {
        public static let title1 = Font.title
        public static let title2 = Font.title2
        public static let title3 = Font.title3
        public static let headline = Font.headline
        public static let body = Font.body
        public static let caption1 = Font.caption
        public static let caption2 = Font.caption2
    }
    
    public enum Spacing {
        public static let xxSmall: CGFloat = 4
        public static let xSmall: CGFloat = 8
        public static let small: CGFloat = 12
        public static let medium: CGFloat = 16
        public static let large: CGFloat = 24
        public static let xLarge: CGFloat = 32
        public static let xxLarge: CGFloat = 48
    }
    
    public enum Radius {
        public static let small: CGFloat = 4
        public static let medium: CGFloat = 8
        public static let large: CGFloat = 16
    }
    
    public enum Shadow {
        public static let medium = Color.black.opacity(0.1)
    }
} 