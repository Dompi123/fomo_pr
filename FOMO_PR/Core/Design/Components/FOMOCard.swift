import SwiftUI

/**
 * FOMOCard: A standardized card component that implements our design system
 * Provides consistent card styling across the app with multiple variants
 */
public struct FOMOCard<Content: View>: View {
    // MARK: - Properties
    
    /// The content to display inside the card
    private let content: Content
    
    /// The style of the card
    private let style: CardStyle
    
    /// Whether the card is interactive (adds hover/press effects)
    private let isInteractive: Bool
    
    /// Optional action to perform when the card is tapped
    private let action: (() -> Void)?
    
    /// The padding to apply to the content
    private let contentPadding: EdgeInsets
    
    /// State for interactive effects
    @State private var isPressed: Bool = false
    
    // MARK: - Initialization
    
    public init(
        style: CardStyle = .primary,
        isInteractive: Bool = false,
        contentPadding: EdgeInsets? = nil,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.style = style
        self.isInteractive = isInteractive
        self.action = action
        self.content = content()
        
        // Default padding based on style
        if let contentPadding = contentPadding {
            self.contentPadding = contentPadding
        } else {
            switch style {
            case .primary, .premium:
                self.contentPadding = EdgeInsets(
                    top: FOMOTheme.Layout.paddingMedium,
                    leading: FOMOTheme.Layout.paddingMedium,
                    bottom: FOMOTheme.Layout.paddingMedium,
                    trailing: FOMOTheme.Layout.paddingMedium
                )
            case .secondary:
                self.contentPadding = EdgeInsets(
                    top: FOMOTheme.Layout.paddingSmall,
                    leading: FOMOTheme.Layout.paddingSmall,
                    bottom: FOMOTheme.Layout.paddingSmall,
                    trailing: FOMOTheme.Layout.paddingSmall
                )
            case .minimal:
                self.contentPadding = EdgeInsets(
                    top: FOMOTheme.Layout.paddingTiny,
                    leading: FOMOTheme.Layout.paddingTiny,
                    bottom: FOMOTheme.Layout.paddingTiny,
                    trailing: FOMOTheme.Layout.paddingTiny
                )
            }
        }
    }
    
    // MARK: - Body
    
    public var body: some View {
        Group {
            if isInteractive {
                Button(action: { action?() }) {
                    cardContent
                }
                .buttonStyle(CardButtonStyle(style: style, isPressed: $isPressed))
            } else {
                cardContent
            }
        }
    }
    
    // MARK: - Private Views
    
    /// The main content of the card
    private var cardContent: some View {
        content
            .padding(contentPadding)
            .frame(maxWidth: .infinity)
            .background(style.backgroundColor)
            .cornerRadius(style.cornerRadius)
            .overlay(
                // Premium highlight for premium cards
                style == .premium ?
                RoundedRectangle(cornerRadius: style.cornerRadius)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                FOMOTheme.Colors.primary,
                                FOMOTheme.Colors.primary.opacity(0.5),
                                FOMOTheme.Colors.primary.opacity(0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
                : nil
            )
            .shadow(
                color: style.shadowColor.opacity(isPressed ? 0.1 : style.shadowOpacity),
                radius: isPressed ? style.shadowRadius * 0.7 : style.shadowRadius,
                x: 0,
                y: isPressed ? 2 : style.shadowY
            )
            .scaleEffect(isInteractive && isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
    
    // MARK: - Card Styles
    
    public enum CardStyle {
        case primary   // Standard card
        case secondary // Less prominent card
        case premium   // Card for premium/featured content
        case minimal   // Minimal card with less styling
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return FOMOTheme.Colors.surface
            case .secondary:
                return FOMOTheme.Colors.surface.opacity(0.8)
            case .premium:
                return FOMOTheme.Colors.surfaceVariant
            case .minimal:
                return FOMOTheme.Colors.surface.opacity(0.5)
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .primary, .premium:
                return FOMOTheme.Layout.cornerRadiusMedium
            case .secondary:
                return FOMOTheme.Layout.cornerRadiusRegular
            case .minimal:
                return FOMOTheme.Layout.cornerRadiusSmall
            }
        }
        
        var shadowColor: Color {
            switch self {
            case .primary, .secondary:
                return Color.black
            case .premium:
                return FOMOTheme.Colors.primary
            case .minimal:
                return Color.black
            }
        }
        
        var shadowOpacity: Double {
            switch self {
            case .primary:
                return 0.25
            case .secondary:
                return 0.15
            case .premium:
                return 0.3
            case .minimal:
                return 0.1
            }
        }
        
        var shadowRadius: CGFloat {
            switch self {
            case .primary:
                return 8
            case .secondary:
                return 6
            case .premium:
                return 10
            case .minimal:
                return 4
            }
        }
        
        var shadowY: CGFloat {
            switch self {
            case .primary:
                return 4
            case .secondary:
                return 3
            case .premium:
                return 5
            case .minimal:
                return 2
            }
        }
    }
}

// MARK: - Button Style for Interactive Cards

private struct CardButtonStyle: ButtonStyle {
    let style: FOMOCard<EmptyView>.CardStyle
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                isPressed = newValue
            }
    }
}

// MARK: - View Extensions

extension View {
    /// Applies card styling to a view
    public func fomoCardStyle(
        _ style: FOMOCard<EmptyView>.CardStyle = .primary,
        isInteractive: Bool = false,
        contentPadding: EdgeInsets? = nil
    ) -> some View {
        FOMOCard(style: style, isInteractive: isInteractive, contentPadding: contentPadding) {
            self
        }
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            // Primary Card
            FOMOCard(style: .primary, isInteractive: true) {
                VStack(alignment: .leading, spacing: 12) {
                    FOMOText("Primary Card", style: .headline)
                    FOMOText("This is a standard card with primary styling. Tap to interact.", style: .body)
                }
            }
            
            // Secondary Card
            FOMOCard(style: .secondary) {
                VStack(alignment: .leading, spacing: 8) {
                    FOMOText("Secondary Card", style: .headline)
                    FOMOText("This card has a more subtle styling for less important content.", style: .body)
                }
            }
            
            // Premium Card
            FOMOCard(style: .premium, isInteractive: true) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        FOMOText("Premium Card", style: .headline)
                        Spacer()
                        Image(systemName: "star.fill")
                            .foregroundColor(FOMOTheme.Colors.primary)
                    }
                    FOMOText("This premium card has special styling to highlight featured content.", style: .body)
                }
            }
            
            // Minimal Card
            FOMOCard(style: .minimal) {
                VStack(alignment: .leading, spacing: 4) {
                    FOMOText("Minimal Card", style: .subheadline)
                    FOMOText("A simple card with minimal styling.", style: .caption)
                }
            }
            
            // Using the modifier
            VStack(alignment: .leading, spacing: 12) {
                FOMOText("Card Using Modifier", style: .headline)
                FOMOText("This card uses the .fomoCardStyle() modifier directly.", style: .body)
            }
            .fomoCardStyle(.primary, isInteractive: true)
        }
        .padding()
    }
    .background(FOMOTheme.Colors.background)
} 