import SwiftUI

/**
 * FOMOToggle: A standardized toggle switch component
 * Provides consistent toggle styling with different sizes and states
 */
public struct FOMOToggle: View {
    // MARK: - Properties
    
    /// Binding to the toggle state
    @Binding private var isOn: Bool
    
    /// Label text to display
    private let label: String
    
    /// Optional secondary text to display below the label
    private let secondaryText: String?
    
    /// Style of the toggle
    private let style: ToggleStyle
    
    /// Size variant of the toggle
    private let size: ToggleSize
    
    /// Whether the toggle is enabled
    private let isEnabled: Bool
    
    /// Optional icon to display next to the label
    private let icon: String?
    
    // MARK: - Initialization
    
    public init(
        isOn: Binding<Bool>,
        label: String,
        secondaryText: String? = nil,
        icon: String? = nil,
        style: ToggleStyle = .primary,
        size: ToggleSize = .medium,
        isEnabled: Bool = true
    ) {
        self._isOn = isOn
        self.label = label
        self.secondaryText = secondaryText
        self.icon = icon
        self.style = style
        self.size = size
        self.isEnabled = isEnabled
    }
    
    // MARK: - Body
    
    public var body: some View {
        Toggle(isOn: $isOn) {
            HStack(spacing: 12) {
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(isEnabled ? style.accentColor : FOMOTheme.Colors.textSecondary.opacity(0.6))
                        .font(size.iconFont)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(label)
                        .font(size.labelFont)
                        .foregroundColor(isEnabled ? FOMOTheme.Colors.text : FOMOTheme.Colors.textSecondary.opacity(0.6))
                    
                    if let secondaryText = secondaryText {
                        Text(secondaryText)
                            .font(size.secondaryFont)
                            .foregroundColor(isEnabled ? FOMOTheme.Colors.textSecondary : FOMOTheme.Colors.textSecondary.opacity(0.6))
                    }
                }
            }
        }
        .toggleStyle(FOMOCustomToggleStyle(style: style, size: size, isEnabled: isEnabled))
        .disabled(!isEnabled)
    }
    
    // MARK: - Toggle Styles
    
    public enum ToggleStyle {
        case primary   // Standard toggle with primary color
        case success   // Success/activated toggle
        case premium   // Premium feature toggle
        case minimal   // Minimal styling
        
        var accentColor: Color {
            switch self {
            case .primary:
                return FOMOTheme.Colors.primary
            case .success:
                return FOMOTheme.Colors.success
            case .premium:
                return FOMOTheme.Colors.accent
            case .minimal:
                return FOMOTheme.Colors.textSecondary
            }
        }
        
        var thumbColor: Color {
            return FOMOTheme.Colors.text
        }
        
        var trackOnColor: Color {
            switch self {
            case .primary:
                return FOMOTheme.Colors.primary
            case .success:
                return FOMOTheme.Colors.success
            case .premium:
                return FOMOTheme.Colors.primary
            case .minimal:
                return FOMOTheme.Colors.surfaceVariant
            }
        }
        
        var trackOffColor: Color {
            return FOMOTheme.Colors.surface
        }
    }
    
    // MARK: - Toggle Sizes
    
    public enum ToggleSize {
        case small
        case medium
        case large
        
        var trackHeight: CGFloat {
            switch self {
            case .small:
                return 24
            case .medium:
                return 28
            case .large:
                return 32
            }
        }
        
        var trackWidth: CGFloat {
            switch self {
            case .small:
                return 44
            case .medium:
                return 52
            case .large:
                return 60
            }
        }
        
        var thumbSize: CGFloat {
            switch self {
            case .small:
                return 18
            case .medium:
                return 22
            case .large:
                return 26
            }
        }
        
        var labelFont: Font {
            switch self {
            case .small:
                return FOMOTheme.Typography.subheadline
            case .medium:
                return FOMOTheme.Typography.body
            case .large:
                return FOMOTheme.Typography.bodyLarge
            }
        }
        
        var secondaryFont: Font {
            switch self {
            case .small, .medium, .large:
                return FOMOTheme.Typography.caption
            }
        }
        
        var iconFont: Font {
            switch self {
            case .small:
                return .system(size: 14)
            case .medium:
                return .system(size: 16)
            case .large:
                return .system(size: 20)
            }
        }
    }
}

// MARK: - Custom Toggle Style

struct FOMOCustomToggleStyle: SwiftUI.ToggleStyle {
    let style: FOMOToggle.ToggleStyle
    let size: FOMOToggle.ToggleSize
    let isEnabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            
            Spacer()
            
            // Custom toggle track and thumb
            ZStack {
                // Track
                RoundedRectangle(cornerRadius: size.trackHeight / 2)
                    .fill(configuration.isOn ? 
                          (isEnabled ? style.trackOnColor : style.trackOnColor.opacity(0.4)) : 
                          (isEnabled ? style.trackOffColor : style.trackOffColor.opacity(0.4)))
                    .frame(width: size.trackWidth, height: size.trackHeight)
                
                // Thumb
                Circle()
                    .fill(isEnabled ? style.thumbColor : style.thumbColor.opacity(0.6))
                    .frame(width: size.thumbSize, height: size.thumbSize)
                    .shadow(color: Color.black.opacity(0.15), radius: 1, x: 0, y: 1)
                    .offset(x: configuration.isOn ? size.trackWidth/2 - size.thumbSize/2 - 2 : -size.trackWidth/2 + size.thumbSize/2 + 2)
                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: configuration.isOn)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if isEnabled {
                withAnimation {
                    configuration.isOn.toggle()
                }
            }
        }
    }
}

// MARK: - Modifiers

extension FOMOToggle {
    /// Set the style of the toggle
    public func toggleStyle(_ style: ToggleStyle) -> FOMOToggle {
        FOMOToggle(
            isOn: $isOn,
            label: label,
            secondaryText: secondaryText,
            icon: icon,
            style: style,
            size: size,
            isEnabled: isEnabled
        )
    }
    
    /// Set the size of the toggle
    public func toggleSize(_ size: ToggleSize) -> FOMOToggle {
        FOMOToggle(
            isOn: $isOn,
            label: label,
            secondaryText: secondaryText,
            icon: icon,
            style: style,
            size: size,
            isEnabled: isEnabled
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: 24) {
        // Standard toggle
        StateWrapper(initialValue: true) { isOn in
            FOMOToggle(
                isOn: isOn,
                label: "Enable notifications",
                secondaryText: "We'll notify you about events near you",
                icon: "bell.fill"
            )
        }
        
        // Success toggle
        StateWrapper(initialValue: true) { isOn in
            FOMOToggle(
                isOn: isOn,
                label: "Location services",
                secondaryText: "Allow access to your location",
                icon: "location.fill",
                style: .success
            )
        }
        
        // Premium toggle
        StateWrapper(initialValue: false) { isOn in
            FOMOToggle(
                isOn: isOn,
                label: "Premium Features",
                secondaryText: "Enable exclusive premium features",
                icon: "star.fill",
                style: .premium
            )
        }
        
        // Disabled toggle
        StateWrapper(initialValue: false) { isOn in
            FOMOToggle(
                isOn: isOn,
                label: "Advanced settings",
                secondaryText: "This feature is not available yet",
                icon: "gearshape.fill",
                isEnabled: false
            )
        }
        
        // Minimal style
        StateWrapper(initialValue: true) { isOn in
            FOMOToggle(
                isOn: isOn,
                label: "Dark mode",
                style: .minimal,
                size: .small
            )
        }
        
        // Large size
        StateWrapper(initialValue: true) { isOn in
            FOMOToggle(
                isOn: isOn,
                label: "Featured notifications",
                secondaryText: "Get notified about featured events",
                icon: "star.fill",
                style: .premium,
                size: .large
            )
        }
    }
    .padding()
    .background(FOMOTheme.Colors.background)
    .preferredColorScheme(.dark)
} 