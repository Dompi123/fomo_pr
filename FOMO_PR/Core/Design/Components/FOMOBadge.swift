import SwiftUI

/// A standardized badge component for the FOMO app.
public struct FOMOBadge: View {
    private let text: String
    private let style: BadgeStyle
    private let isAnimated: Bool
    
    public enum BadgeStyle {
        case standard
        case accent
        case featured
        case outline
    }
    
    /// Initialize a new FOMOBadge
    /// - Parameters:
    ///   - text: The badge text
    ///   - style: Badge style (standard, accent, featured, or outline)
    ///   - isAnimated: Whether the badge should animate on appearance
    public init(
        _ text: String,
        style: BadgeStyle = .standard,
        isAnimated: Bool = false
    ) {
        self.text = text
        self.style = style
        self.isAnimated = isAnimated
    }
    
    public var body: some View {
        Text(text)
            .font(TypographySystem.font(weight: .medium, size: .xSmall))
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(borderColor, lineWidth: style == .outline ? 1 : 0)
            )
            .opacity(isAnimated ? 0 : 1)
            .onAppear {
                if isAnimated {
                    withAnimation(AnimationSystem.Curve.bouncySpring(duration: AnimationSystem.Duration.medium)) {
                        Text(text)
                            .font(TypographySystem.font(weight: .medium, size: .xSmall))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(backgroundColor)
                            .foregroundColor(foregroundColor)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(borderColor, lineWidth: style == .outline ? 1 : 0)
                            )
                            .opacity(1)
                            .scaleEffect(1)
                    }
                }
            }
    }
    
    private var backgroundColor: Color {
        switch style {
        case .standard:
            return ColorSystem.Brand.primary
        case .accent:
            return ColorSystem.Brand.accent
        case .featured:
            return ColorSystem.Brand.secondary
        case .outline:
            return .clear
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .standard, .accent, .featured:
            return .white
        case .outline:
            return ColorSystem.Text.primary
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .standard, .accent, .featured:
            return .clear
        case .outline:
            return ColorSystem.Brand.primary
        }
    }
}

#if DEBUG
struct FOMOBadge_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            FOMOBadge("PREMIUM", style: .standard)
            
            FOMOBadge("NEW", style: .accent)
            
            FOMOBadge("FEATURED", style: .featured)
            
            FOMOBadge("POPULAR", style: .outline)
            
            FOMOBadge("ANIMATED", style: .accent, isAnimated: true)
        }
        .padding()
        .background(ColorSystem.Background.primary)
        .previewLayout(.sizeThatFits)
    }
}
#endif 