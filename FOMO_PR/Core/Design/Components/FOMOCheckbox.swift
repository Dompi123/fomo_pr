import SwiftUI

/**
 * FOMOCheckbox: A standardized checkbox component
 * Provides consistent checkbox/radio styling with different states and appearances
 */
public struct FOMOCheckbox: View {
    // MARK: - Properties
    
    /// Binding to the isSelected state
    @Binding private var isSelected: Bool
    
    /// Label text to display
    private let label: String
    
    /// Optional secondary text to display below the label
    private let secondaryText: String?
    
    /// Style of the checkbox
    private let style: CheckboxStyle
    
    /// Whether the checkbox is enabled
    private let isEnabled: Bool
    
    /// Optional icon to display next to the label
    private let icon: String?
    
    /// Size variant of the checkbox
    private let size: CheckboxSize
    
    /// Action to perform when the checkbox state changes
    private let action: ((Bool) -> Void)?
    
    // MARK: - Initialization
    
    public init(
        isSelected: Binding<Bool>,
        label: String,
        secondaryText: String? = nil,
        icon: String? = nil,
        style: CheckboxStyle = .checkbox,
        size: CheckboxSize = .medium,
        isEnabled: Bool = true,
        action: ((Bool) -> Void)? = nil
    ) {
        self._isSelected = isSelected
        self.label = label
        self.secondaryText = secondaryText
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
                isSelected.toggle()
                action?(isSelected)
            }
        }) {
            HStack(alignment: .center, spacing: 12) {
                // Checkbox/Radio indicator
                indicator
                
                // Label content
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        // Optional icon
                        if let icon = icon {
                            Image(systemName: icon)
                                .foregroundColor(isEnabled ? 
                                              (isSelected ? style.accentColor : FOMOTheme.Colors.textSecondary) : 
                                              FOMOTheme.Colors.textSecondary.opacity(0.6))
                                .font(size.iconFont)
                        }
                        
                        // Main label
                        Text(label)
                            .font(size.labelFont)
                            .foregroundColor(isEnabled ? FOMOTheme.Colors.text : FOMOTheme.Colors.textSecondary.opacity(0.6))
                    }
                    
                    // Secondary text if provided
                    if let secondaryText = secondaryText {
                        Text(secondaryText)
                            .font(size.secondaryFont)
                            .foregroundColor(isEnabled ? FOMOTheme.Colors.textSecondary : FOMOTheme.Colors.textSecondary.opacity(0.6))
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .contentShape(Rectangle())
    }
    
    // MARK: - Indicator View
    
    @ViewBuilder
    private var indicator: some View {
        switch style.type {
        case .checkbox:
            // Checkbox square
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: size.cornerRadius)
                    .stroke(
                        isEnabled ?
                        (isSelected ? style.accentColor : FOMOTheme.Colors.textSecondary.opacity(0.8)) :
                        FOMOTheme.Colors.textSecondary.opacity(0.4),
                        lineWidth: size.borderWidth
                    )
                    .frame(width: size.indicatorSize, height: size.indicatorSize)
                    .background(
                        RoundedRectangle(cornerRadius: size.cornerRadius)
                            .fill(isSelected ? style.accentColor.opacity(0.2) : Color.clear)
                    )
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: size.checkmarkSize, weight: .bold))
                        .foregroundColor(isEnabled ? style.accentColor : style.accentColor.opacity(0.6))
                }
            }
            
        case .radio:
            // Radio circle
            ZStack {
                // Outer circle
                Circle()
                    .stroke(
                        isEnabled ?
                        (isSelected ? style.accentColor : FOMOTheme.Colors.textSecondary.opacity(0.8)) :
                        FOMOTheme.Colors.textSecondary.opacity(0.4),
                        lineWidth: size.borderWidth
                    )
                    .frame(width: size.indicatorSize, height: size.indicatorSize)
                
                // Inner circle when selected
                if isSelected {
                    Circle()
                        .fill(isEnabled ? style.accentColor : style.accentColor.opacity(0.6))
                        .frame(width: size.indicatorSize - 8, height: size.indicatorSize - 8)
                }
            }
            
        case .switch:
            // Switch-style indicator (custom mini toggle)
            ZStack {
                // Track
                Capsule()
                    .fill(isSelected ? 
                         (isEnabled ? style.accentColor : style.accentColor.opacity(0.4)) : 
                         (isEnabled ? FOMOTheme.Colors.surface : FOMOTheme.Colors.surface.opacity(0.4)))
                    .frame(width: size.switchWidth, height: size.switchHeight)
                
                // Thumb
                Circle()
                    .fill(FOMOTheme.Colors.text)
                    .frame(width: size.switchHeight - 4, height: size.switchHeight - 4)
                    .offset(x: isSelected ? (size.switchWidth / 2) - (size.switchHeight / 2) : -((size.switchWidth / 2) - (size.switchHeight / 2)))
                    .animation(.spring(response: 0.2, dampingFraction: 0.8), value: isSelected)
            }
            .frame(width: size.switchWidth, height: size.switchHeight)
        }
    }
    
    // MARK: - Checkbox Styles
    
    public enum CheckboxStyle {
        case primary
        case success
        case premium
        case minimal
        case checkbox
        case radio
        case `switch`
        
        /// The type of checkbox visual indicator
        var type: IndicatorType {
            switch self {
            case .checkbox:
                return .checkbox
            case .radio:
                return .radio
            case .switch:
                return .switch
            case .primary, .success, .premium, .minimal:
                return .checkbox
            }
        }
        
        /// The accent color for the checkbox
        var accentColor: Color {
            switch self {
            case .primary, .checkbox, .radio, .switch:
                return FOMOTheme.Colors.primary
            case .success:
                return FOMOTheme.Colors.success
            case .premium:
                return FOMOTheme.Colors.accent
            case .minimal:
                return FOMOTheme.Colors.textSecondary
            }
        }
        
        /// Types of visual indicators for the checkbox
        enum IndicatorType {
            case checkbox
            case radio
            case `switch`
        }
    }
    
    // MARK: - Checkbox Sizes
    
    public enum CheckboxSize {
        case small
        case medium
        case large
        
        var indicatorSize: CGFloat {
            switch self {
            case .small:
                return 18
            case .medium:
                return 22
            case .large:
                return 26
            }
        }
        
        var checkmarkSize: CGFloat {
            switch self {
            case .small:
                return 10
            case .medium:
                return 14
            case .large:
                return 16
            }
        }
        
        var switchWidth: CGFloat {
            switch self {
            case .small:
                return 30
            case .medium:
                return 36
            case .large:
                return 42
            }
        }
        
        var switchHeight: CGFloat {
            switch self {
            case .small:
                return 16
            case .medium:
                return 20
            case .large:
                return 24
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small:
                return 3
            case .medium:
                return 4
            case .large:
                return 5
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .small:
                return 1.5
            case .medium:
                return 2
            case .large:
                return 2.5
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
            return FOMOTheme.Typography.caption
        }
        
        var iconFont: Font {
            switch self {
            case .small:
                return .system(size: 14)
            case .medium:
                return .system(size: 16)
            case .large:
                return .system(size: 18)
            }
        }
    }
}

// MARK: - Modifiers

extension FOMOCheckbox {
    /// Set the style of the checkbox
    public func checkboxStyle(_ style: CheckboxStyle) -> FOMOCheckbox {
        FOMOCheckbox(
            isSelected: $isSelected,
            label: label,
            secondaryText: secondaryText,
            icon: icon,
            style: style,
            size: size,
            isEnabled: isEnabled,
            action: action
        )
    }
    
    /// Set the size of the checkbox
    public func checkboxSize(_ size: CheckboxSize) -> FOMOCheckbox {
        FOMOCheckbox(
            isSelected: $isSelected,
            label: label,
            secondaryText: secondaryText,
            icon: icon,
            style: style,
            size: size,
            isEnabled: isEnabled,
            action: action
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(alignment: .leading, spacing: 24) {
        Group {
            FOMOText("Checkbox Examples", style: .headline)
            
            // Standard checkbox
            StateWrapper(initialValue: true) { isSelected in
                FOMOCheckbox(
                    isSelected: isSelected,
                    label: "Terms and Conditions",
                    secondaryText: "I agree to the terms of service",
                    icon: "doc.text",
                    style: .checkbox
                )
            }
            
            // Premium style
            StateWrapper(initialValue: false) { isSelected in
                FOMOCheckbox(
                    isSelected: isSelected,
                    label: "Premium Features",
                    secondaryText: "Unlock exclusive content",
                    icon: "star.fill",
                    style: .premium
                )
            }
            
            // Disabled checkbox
            StateWrapper(initialValue: true) { isSelected in
                FOMOCheckbox(
                    isSelected: isSelected,
                    label: "Currently Unavailable",
                    secondaryText: "This option cannot be changed",
                    icon: "lock.fill",
                    isEnabled: false
                )
            }
        }
        
        Group {
            FOMOText("Radio Examples", style: .headline)
            
            // Radio button
            StateWrapper(initialValue: true) { isSelected in
                FOMOCheckbox(
                    isSelected: isSelected,
                    label: "Standard Ticket",
                    secondaryText: "$29.99 - General admission",
                    icon: "ticket",
                    style: .radio
                )
            }
            
            StateWrapper(initialValue: false) { isSelected in
                FOMOCheckbox(
                    isSelected: isSelected,
                    label: "VIP Ticket",
                    secondaryText: "$99.99 - VIP admission with perks",
                    icon: "ticket.fill",
                    style: .radio
                )
            }
        }
        
        Group {
            FOMOText("Switch Examples", style: .headline)
            
            // Switch style
            StateWrapper(initialValue: true) { isSelected in
                FOMOCheckbox(
                    isSelected: isSelected,
                    label: "Push Notifications",
                    secondaryText: "Receive alerts about events",
                    icon: "bell.fill",
                    style: .switch
                )
            }
            
            // Success style switch
            StateWrapper(initialValue: true) { isSelected in
                FOMOCheckbox(
                    isSelected: isSelected,
                    label: "Location Services",
                    secondaryText: "Allow access to your location",
                    icon: "location.fill",
                    style: .success
                )
                .checkboxStyle(.switch)
            }
        }
        
        Group {
            FOMOText("Size Variants", style: .headline)
            
            StateWrapper(initialValue: true) { isSelected in
                FOMOCheckbox(
                    isSelected: isSelected,
                    label: "Small Size",
                    style: .checkbox,
                    size: .small
                )
            }
            
            StateWrapper(initialValue: true) { isSelected in
                FOMOCheckbox(
                    isSelected: isSelected,
                    label: "Large Size",
                    style: .checkbox,
                    size: .large
                )
            }
        }
    }
    .padding()
    .background(FOMOTheme.Colors.background)
    .preferredColorScheme(.dark)
} 