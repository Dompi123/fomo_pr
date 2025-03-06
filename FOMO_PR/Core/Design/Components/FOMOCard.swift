import SwiftUI

/// A standardized card view for displaying content with consistent styling.
public struct FOMOCard<Content: View>: View {
    private let content: Content
    private let padding: CardPadding
    private let backgroundColor: Color
    private let cornerRadius: CGFloat
    
    public enum CardPadding {
        case none
        case small
        case medium
        case large
        
        var value: CGFloat {
            switch self {
            case .none: return 0
            case .small: return FOMOTheme.Spacing.small
            case .medium: return FOMOTheme.Spacing.medium
            case .large: return FOMOTheme.Spacing.large
            }
        }
    }
    
    /// Initialize a new FOMOCard
    /// - Parameters:
    ///   - padding: Amount of padding to apply to the content
    ///   - backgroundColor: Background color of the card
    ///   - cornerRadius: Corner radius of the card
    ///   - content: Content to display inside the card
    public init(
        padding: CardPadding = .medium,
        backgroundColor: Color = FOMOTheme.Colors.surface,
        cornerRadius: CGFloat = FOMOTheme.Radius.medium,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    public var body: some View {
        content
            .padding(padding.value)
            .background(backgroundColor)
            .cornerRadius(cornerRadius)
            .shadow(
                color: FOMOTheme.Shadow.medium,
                radius: 4,
                x: 0,
                y: 2
            )
    }
}

// Convenience extension to apply card styling to any view
public extension View {
    /// Wraps this view in a FOMOCard with the specified parameters
    func asCard(
        padding: FOMOCard<Self>.CardPadding = .medium,
        backgroundColor: Color = FOMOTheme.Colors.surface,
        cornerRadius: CGFloat = FOMOTheme.Radius.medium
    ) -> some View {
        FOMOCard(
            padding: padding,
            backgroundColor: backgroundColor,
            cornerRadius: cornerRadius
        ) {
            self
        }
    }
}

#if DEBUG
struct FOMOCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Standard card
            FOMOCard {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Card Title")
                        .font(FOMOTheme.Typography.headlineMedium)
                    
                    Text("This is a standard card with medium padding and default styling.")
                        .font(FOMOTheme.Typography.bodyRegular)
                }
            }
            
            // Card with custom parameters
            FOMOCard(
                padding: .large,
                backgroundColor: FOMOTheme.Colors.primary.opacity(0.1),
                cornerRadius: FOMOTheme.Radius.large
            ) {
                Text("Custom Card")
                    .font(FOMOTheme.Typography.bodyLarge)
            }
            
            // Using the extension
            VStack(alignment: .leading) {
                Text("Extension Card")
                    .font(FOMOTheme.Typography.headlineSmall)
                Text("Created using the .asCard() extension")
                    .font(FOMOTheme.Typography.caption1)
            }
            .asCard(padding: .small)
        }
        .padding()
        .background(FOMOTheme.Colors.background)
        .previewLayout(.sizeThatFits)
    }
} 