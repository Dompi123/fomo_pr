import SwiftUI

/// A standardized button for the FOMO app that applies consistent styling.
public struct FOMOButton: View {
    private let title: String
    private let action: () -> Void
    private let style: ButtonStyle
    private let isEnabled: Bool
    
    public enum ButtonStyle {
        case primary
        case secondary
        case text
    }
    
    /// Initialize a new FOMOButton
    /// - Parameters:
    ///   - title: The button text
    ///   - style: Button style (primary, secondary, or text)
    ///   - isEnabled: Whether the button is enabled
    ///   - action: The action to perform when tapped
    public init(
        _ title: String,
        style: ButtonStyle = .primary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
    }
    
    public var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            Text(title)
                .font(FOMOTheme.Typography.bodyLarge)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity)
                .padding(.vertical, FOMOTheme.Spacing.small)
                .padding(.horizontal, FOMOTheme.Spacing.medium)
        }
        .background(backgroundColor)
        .foregroundColor(foregroundColor)
        .cornerRadius(FOMOTheme.Radius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: FOMOTheme.Radius.medium)
                .stroke(borderColor, lineWidth: style == .secondary ? 1 : 0)
        )
        .opacity(isEnabled ? 1.0 : 0.6)
    }
    
    private var backgroundColor: Color {
        if !isEnabled {
            return style == .text ? .clear : FOMOTheme.Colors.surface
        }
        
        switch style {
        case .primary:
            return FOMOTheme.Colors.primary
        case .secondary:
            return .clear
        case .text:
            return .clear
        }
    }
    
    private var foregroundColor: Color {
        if !isEnabled {
            return FOMOTheme.Colors.textSecondary
        }
        
        switch style {
        case .primary:
            return .white
        case .secondary, .text:
            return FOMOTheme.Colors.text
        }
    }
    
    private var borderColor: Color {
        if !isEnabled {
            return FOMOTheme.Colors.textSecondary
        }
        
        switch style {
        case .primary, .text:
            return .clear
        case .secondary:
            return FOMOTheme.Colors.primary
        }
    }
}

#if DEBUG
struct FOMOButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            FOMOButton("Primary Button", style: .primary) {
                print("Primary tapped")
            }
            
            FOMOButton("Secondary Button", style: .secondary) {
                print("Secondary tapped")
            }
            
            FOMOButton("Text Button", style: .text) {
                print("Text tapped")
            }
            
            FOMOButton("Disabled Button", style: .primary, isEnabled: false) {
                print("Should not be called")
            }
        }
        .padding()
        .background(FOMOTheme.Colors.background)
        .previewLayout(.sizeThatFits)
    }
} 