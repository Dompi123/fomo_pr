import SwiftUI

/**
 * FOMOButton: A standardized button component that implements our design system
 * Provides consistent button styling across the app with multiple variants
 */
public struct FOMOButton: View {
    // MARK: - Properties
    
    /// The label text to display in the button
    private let label: String
    
    /// The icon to display (optional)
    private let icon: String?
    
    /// The button style
    private let style: ButtonStyle
    
    /// The button size
    private let size: ButtonSize
    
    /// The action to perform when the button is tapped
    private let action: () -> Void
    
    /// Whether the button is enabled
    private let isEnabled: Bool
    
    /// State for tracking button press
    @State private var isPressed: Bool = false
    
    // MARK: - Initialization
    
    public init(
        _ label: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.icon = icon
        self.style = style
        self.size = size
        self.isEnabled = isEnabled
        self.action = action
    }
    
    // MARK: - Body
    
    public var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            HStack(spacing: 8) {
                // Icon if provided
                if let icon = icon {
                    Image(systemName: icon)
                        .font(size.iconFont)
                }
                
                // Text label
                Text(label)
                    .font(size.font)
                    .fontWeight(.semibold)
            }
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .frame(maxWidth: style.isFullWidth ? .infinity : nil)
        }
        .background(
            // Apply gradient for special looks
            Group {
                if isEnabled {
                    if style == .primary || style == .premium {
                        LinearGradient(
                            colors: style == .premium ? [
                                FOMOTheme.Colors.primary,
                                FOMOTheme.Colors.primaryVariant
                            ] : [
                                style.backgroundColor,
                                style.backgroundColor.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        style.backgroundColor
                    }
                } else {
                    style.disabledBackgroundColor
                }
            }
        )
        .foregroundColor(isEnabled ? style.foregroundColor : style.disabledForegroundColor)
        .cornerRadius(size.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: size.cornerRadius)
                .strokeBorder(
                    style == .outline ? 
                        (isEnabled ? style.outlineColor : style.disabledOutlineColor) : 
                        Color.clear,
                    lineWidth: 1.5
                )
        )
        .shadow(
            color: isEnabled ? style.shadowColor.opacity(isPressed ? 0.1 : 0.2) : Color.clear,
            radius: isPressed ? 2 : 4,
            x: 0,
            y: isPressed ? 1 : 2
        )
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isPressed)
        .disabled(!isEnabled)
        .contentShape(Rectangle())
        .pressAction(
            onPress: { isPressed = true },
            onRelease: { isPressed = false }
        )
    }
    
    // MARK: - Button Styles
    
    public enum ButtonStyle {
        case primary   // Main call to action
        case secondary // Less prominent option
        case premium   // Special premium action
        case outline   // Outlined button
        case ghost     // Text-only button
        
        /// Whether the button should expand to full width
        var isFullWidth: Bool {
            switch self {
            case .primary, .premium:
                return true
            default:
                return false
            }
        }
        
        /// Background color based on style
        var backgroundColor: Color {
            switch self {
            case .primary:
                return FOMOTheme.Colors.primary
            case .secondary:
                return FOMOTheme.Colors.surfaceVariant
            case .premium:
                return FOMOTheme.Colors.primary
            case .outline, .ghost:
                return Color.clear
            }
        }
        
        /// Text color based on style
        var foregroundColor: Color {
            switch self {
            case .primary, .premium:
                return .white
            case .secondary:
                return FOMOTheme.Colors.text
            case .outline:
                return FOMOTheme.Colors.primary
            case .ghost:
                return FOMOTheme.Colors.text
            }
        }
        
        /// Disabled background color
        var disabledBackgroundColor: Color {
            switch self {
            case .primary, .premium, .secondary:
                return FOMOTheme.Colors.surface.opacity(0.5)
            case .outline, .ghost:
                return Color.clear
            }
        }
        
        /// Disabled text color
        var disabledForegroundColor: Color {
            return FOMOTheme.Colors.textSecondary.opacity(0.6)
        }
        
        /// Outline color for outline buttons
        var outlineColor: Color {
            return FOMOTheme.Colors.primary
        }
        
        /// Disabled outline color
        var disabledOutlineColor: Color {
            return FOMOTheme.Colors.textSecondary.opacity(0.3)
        }
        
        /// Shadow color based on style
        var shadowColor: Color {
            switch self {
            case .primary, .premium:
                return FOMOTheme.Colors.primary
            case .secondary:
                return Color.black
            case .outline, .ghost:
                return Color.clear
            }
        }
    }
    
    // MARK: - Button Sizes
    
    public enum ButtonSize {
        case small
        case medium
        case large
        
        /// Button height based on size
        var height: CGFloat {
            switch self {
            case .small:
                return 36
            case .medium:
                return 44
            case .large:
                return 56
            }
        }
        
        /// Text font based on size
        var font: Font {
            switch self {
            case .small:
                return FOMOTheme.Typography.caption
            case .medium:
                return FOMOTheme.Typography.button
            case .large:
                return FOMOTheme.Typography.body
            }
        }
        
        /// Icon font based on size
        var iconFont: Font {
            switch self {
            case .small:
                return .system(size: 14, weight: .semibold)
            case .medium:
                return .system(size: 16, weight: .semibold)
            case .large:
                return .system(size: 18, weight: .semibold)
            }
        }
        
        /// Horizontal padding
        var horizontalPadding: CGFloat {
            switch self {
            case .small:
                return FOMOTheme.Layout.paddingSmall
            case .medium:
                return FOMOTheme.Layout.paddingMedium
            case .large:
                return FOMOTheme.Layout.paddingLarge
            }
        }
        
        /// Corner radius
        var cornerRadius: CGFloat {
            switch self {
            case .small:
                return FOMOTheme.Layout.cornerRadiusSmall
            case .medium:
                return FOMOTheme.Layout.cornerRadiusRegular
            case .large:
                return FOMOTheme.Layout.cornerRadiusMedium
            }
        }
    }
}

// MARK: - Press Action Modifier

extension View {
    func pressAction(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressActionModifier(onPress: onPress, onRelease: onRelease))
    }
}

struct PressActionModifier: ViewModifier {
    let onPress: () -> Void
    let onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

// MARK: - View Extensions

extension View {
    /// Applies FOMO button styling to this view
    public func fomoButtonStyle(
        style: FOMOButton.ButtonStyle = .primary,
        size: FOMOButton.ButtonSize = .medium,
        isEnabled: Bool = true
    ) -> some View {
        self
            .font(size.font)
            .fontWeight(.semibold)
            .frame(height: size.height)
            .padding(.horizontal, size.horizontalPadding)
            .frame(maxWidth: style.isFullWidth ? .infinity : nil)
            .foregroundColor(isEnabled ? style.foregroundColor : style.disabledForegroundColor)
            .background(isEnabled ? style.backgroundColor : style.disabledBackgroundColor)
            .cornerRadius(size.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .strokeBorder(
                        style == .outline ? 
                            (isEnabled ? style.outlineColor : style.disabledOutlineColor) : 
                            Color.clear,
                        lineWidth: 1.5
                    )
            )
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            Group {
                FOMOText("Primary Buttons", style: .headline)
                FOMOButton("Primary Button", icon: "cart.fill", action: {})
                FOMOButton("Primary Disabled", icon: "cart.fill", isEnabled: false, action: {})
            }
            
            Group {
                FOMOText("Premium Buttons", style: .headline)
                FOMOButton("Premium Button", icon: "star.fill", style: .premium, action: {})
                FOMOButton("Premium Disabled", icon: "star.fill", style: .premium, isEnabled: false, action: {})
            }
            
            Group {
                FOMOText("Secondary Buttons", style: .headline)
                FOMOButton("Secondary Button", style: .secondary, action: {})
                FOMOButton("Secondary Disabled", style: .secondary, isEnabled: false, action: {})
            }
            
            Group {
                FOMOText("Outline Buttons", style: .headline)
                FOMOButton("Outline Button", style: .outline, action: {})
                FOMOButton("Outline Disabled", style: .outline, isEnabled: false, action: {})
            }
            
            Group {
                FOMOText("Ghost Buttons", style: .headline)
                FOMOButton("Ghost Button", style: .ghost, action: {})
                FOMOButton("Ghost Disabled", style: .ghost, isEnabled: false, action: {})
            }
            
            Group {
                FOMOText("Button Sizes", style: .headline)
                FOMOButton("Small Button", size: .small, action: {})
                FOMOButton("Medium Button", size: .medium, action: {})
                FOMOButton("Large Button", size: .large, action: {})
            }
        }
        .padding()
    }
    .background(FOMOTheme.Colors.background)
} 