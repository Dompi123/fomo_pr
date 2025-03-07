import SwiftUI

/**
 * FOMOTag: A standardized tag component for consistent labeling across the app
 * Used for categories, status indicators, and feature labels
 */
public struct FOMOTag: View {
    // MARK: - Properties
    
    /// The label text to display in the tag
    private let label: String
    
    /// Optional icon to display
    private let icon: String?
    
    /// Style of the tag
    private let style: TagStyle
    
    /// Size of the tag
    private let size: TagSize
    
    // MARK: - Initialization
    
    public init(
        _ label: String,
        icon: String? = nil,
        style: TagStyle = .primary,
        size: TagSize = .medium
    ) {
        self.label = label
        self.icon = icon
        self.style = style
        self.size = size
    }
    
    // MARK: - Body
    
    public var body: some View {
        HStack(spacing: size.iconSpacing) {
            // Icon if provided
            if let icon = icon {
                Image(systemName: icon)
                    .font(size.iconFont)
            }
            
            // Text label
            Text(label)
                .font(size.font)
                .fontWeight(.medium)
                .lineLimit(1)
        }
        .padding(.horizontal, size.horizontalPadding)
        .padding(.vertical, size.verticalPadding)
        .foregroundColor(style.foregroundColor)
        .background(
            Group {
                if style == .premium {
                    // Gradient background for premium tags
                    LinearGradient(
                        colors: [
                            FOMOTheme.Colors.primary.opacity(0.7),
                            FOMOTheme.Colors.primary.opacity(0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                } else {
                    // Solid color for other tags
                    style.backgroundColor
                }
            }
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(
                    style == .outline ? style.borderColor : Color.clear,
                    lineWidth: 1
                )
        )
        .shadow(
            color: style.shadowColor.opacity(0.2),
            radius: 2,
            x: 0,
            y: 1
        )
    }
    
    // MARK: - Tag Styles
    
    public enum TagStyle {
        case primary   // Standard tag
        case secondary // Subdued tag
        case premium   // Premium/featured tag
        case success   // Success/positive tag
        case warning   // Warning tag
        case error     // Error tag
        case outline   // Outlined tag
        
        /// Background color based on style
        var backgroundColor: Color {
            switch self {
            case .primary:
                return FOMOTheme.Colors.primary.opacity(0.2)
            case .secondary:
                return FOMOTheme.Colors.surface
            case .premium:
                return FOMOTheme.Colors.primary.opacity(0.2)
            case .success:
                return FOMOTheme.Colors.success.opacity(0.2)
            case .warning:
                return FOMOTheme.Colors.warning.opacity(0.2)
            case .error:
                return FOMOTheme.Colors.error.opacity(0.2)
            case .outline:
                return .clear
            }
        }
        
        /// Text color based on style
        var foregroundColor: Color {
            switch self {
            case .primary:
                return FOMOTheme.Colors.primary
            case .secondary:
                return FOMOTheme.Colors.textSecondary
            case .premium:
                return .white
            case .success:
                return FOMOTheme.Colors.success
            case .warning:
                return FOMOTheme.Colors.warning
            case .error:
                return FOMOTheme.Colors.error
            case .outline:
                return FOMOTheme.Colors.text
            }
        }
        
        /// Border color for outline style
        var borderColor: Color {
            switch self {
            case .outline:
                return FOMOTheme.Colors.textSecondary.opacity(0.3)
            default:
                return .clear
            }
        }
        
        /// Shadow color based on style
        var shadowColor: Color {
            switch self {
            case .premium:
                return FOMOTheme.Colors.primary
            case .success:
                return FOMOTheme.Colors.success
            case .warning:
                return FOMOTheme.Colors.warning
            case .error:
                return FOMOTheme.Colors.error
            default:
                return Color.black.opacity(0.1)
            }
        }
    }
    
    // MARK: - Tag Sizes
    
    public enum TagSize {
        case small
        case medium
        case large
        
        /// Horizontal padding
        var horizontalPadding: CGFloat {
            switch self {
            case .small:
                return 8
            case .medium:
                return 12
            case .large:
                return 16
            }
        }
        
        /// Vertical padding
        var verticalPadding: CGFloat {
            switch self {
            case .small:
                return 2
            case .medium:
                return 4
            case .large:
                return 8
            }
        }
        
        /// Text font
        var font: Font {
            switch self {
            case .small:
                return FOMOTheme.Typography.caption
            case .medium:
                return FOMOTheme.Typography.subheadline
            case .large:
                return FOMOTheme.Typography.body
            }
        }
        
        /// Icon font
        var iconFont: Font {
            switch self {
            case .small:
                return .system(size: 10)
            case .medium:
                return .system(size: 12)
            case .large:
                return .system(size: 14)
            }
        }
        
        /// Spacing between icon and text
        var iconSpacing: CGFloat {
            switch self {
            case .small:
                return 4
            case .medium:
                return 6
            case .large:
                return 8
            }
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Applies FOMO tag styling to this view
    public func fomoTagStyle(
        style: FOMOTag.TagStyle = .primary,
        size: FOMOTag.TagSize = .medium
    ) -> some View {
        self
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .font(size.font)
            .fontWeight(.medium)
            .foregroundColor(style.foregroundColor)
            .background(style.backgroundColor)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(
                        style == .outline ? style.borderColor : Color.clear,
                        lineWidth: 1
                    )
            )
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            // Standard tags
            Group {
                FOMOText("Tag Styles", style: .headline)
                
                HStack {
                    FOMOTag("Primary", icon: "tag.fill", style: .primary)
                    FOMOTag("Secondary", style: .secondary)
                    FOMOTag("Premium", icon: "star.fill", style: .premium)
                }
                
                HStack {
                    FOMOTag("Success", icon: "checkmark.circle.fill", style: .success)
                    FOMOTag("Warning", icon: "exclamationmark.triangle.fill", style: .warning)
                    FOMOTag("Error", icon: "xmark.circle.fill", style: .error)
                }
                
                FOMOTag("Outline", icon: "circle", style: .outline)
            }
            
            // Size variations
            Group {
                FOMOText("Tag Sizes", style: .headline)
                
                FOMOTag("Small Tag", size: .small)
                FOMOTag("Medium Tag", size: .medium)
                FOMOTag("Large Tag", size: .large)
            }
            
            // Real-world examples
            Group {
                FOMOText("Use Cases", style: .headline)
                
                HStack {
                    FOMOTag("Popular", icon: "flame.fill", style: .primary)
                    FOMOTag("Trending", icon: "chart.line.uptrend.xyaxis", style: .primary)
                    FOMOTag("Live Music", icon: "music.note", style: .secondary)
                }
                
                HStack {
                    FOMOTag("VIP Only", icon: "star.fill", style: .premium)
                    FOMOTag("Open Now", icon: "checkmark.circle.fill", style: .success)
                    FOMOTag("Almost Full", icon: "person.2.fill", style: .warning)
                }
            }
        }
        .padding()
    }
    .background(FOMOTheme.Colors.background)
} 