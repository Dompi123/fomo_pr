import SwiftUI

/// A showcase view for all the design system elements
public struct DesignShowcase: View {
    @State private var isAnimated = false
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Header with jumbo text
                Text("Design System")
                    .font(TypographySystem.font(weight: .bold, size: .jumbo))
                    .foregroundColor(ColorSystem.Text.primary)
                
                // Color showcase
                colorShowcase
                
                // Typography showcase
                typographyShowcase
                
                // Animation showcase
                animationShowcase
                
                // Component showcase
                componentShowcase
            }
            .padding()
            .background(ColorSystem.Background.primary)
        }
    }
    
    private var colorShowcase: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Colors")
                .font(TypographySystem.font(weight: .bold, size: .large))
                .foregroundColor(ColorSystem.Text.primary)
            
            Text("Brand Colors")
                .font(TypographySystem.font(weight: .medium, size: .medium))
                .foregroundColor(ColorSystem.Text.secondary)
            
            HStack(spacing: 12) {
                colorBox(color: ColorSystem.Brand.primary, name: "Primary")
                colorBox(color: ColorSystem.Brand.secondary, name: "Secondary")
                colorBox(color: ColorSystem.Brand.tertiary, name: "Tertiary")
                colorBox(color: ColorSystem.Brand.accent, name: "Accent")
            }
            
            Text("Status Colors")
                .font(TypographySystem.font(weight: .medium, size: .medium))
                .foregroundColor(ColorSystem.Text.secondary)
            
            HStack(spacing: 12) {
                colorBox(color: ColorSystem.Status.success, name: "Success")
                colorBox(color: ColorSystem.Status.warning, name: "Warning")
                colorBox(color: ColorSystem.Status.error, name: "Error")
                colorBox(color: ColorSystem.Status.info, name: "Info")
            }
        }
        .padding()
        .background(ColorSystem.Background.secondary)
        .cornerRadius(12)
    }
    
    private func colorBox(color: Color, name: String) -> some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 60)
            
            Text(name)
                .font(TypographySystem.font(weight: .medium, size: .xSmall))
                .foregroundColor(ColorSystem.Text.secondary)
        }
    }
    
    private var typographyShowcase: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Typography")
                .font(TypographySystem.font(weight: .bold, size: .large))
                .foregroundColor(ColorSystem.Text.primary)
            
            Group {
                textRow(size: "Jumbo", example: "The quick brown fox", font: TypographySystem.font(weight: .bold, size: .jumbo))
                
                textRow(size: "XXX Large", example: "The quick brown fox", font: TypographySystem.font(weight: .bold, size: .xxxLarge))
                
                textRow(size: "XX Large", example: "The quick brown fox", font: TypographySystem.font(weight: .bold, size: .xxLarge))
                
                textRow(size: "X Large", example: "The quick brown fox", font: TypographySystem.font(weight: .semibold, size: .xLarge))
                
                textRow(size: "Large", example: "The quick brown fox", font: TypographySystem.font(weight: .medium, size: .large))
                
                textRow(size: "Medium", example: "The quick brown fox", font: TypographySystem.font(weight: .regular, size: .medium))
                
                textRow(size: "Small", example: "The quick brown fox", font: TypographySystem.font(weight: .regular, size: .small))
            }
        }
        .padding()
        .background(ColorSystem.Background.secondary)
        .cornerRadius(12)
    }
    
    private func textRow(size: String, example: String, font: Font) -> some View {
        HStack {
            Text(size)
                .font(TypographySystem.font(weight: .medium, size: .small))
                .foregroundColor(ColorSystem.Text.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(example)
                .font(font)
                .foregroundColor(ColorSystem.Text.primary)
        }
    }
    
    private var animationShowcase: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Animations")
                .font(TypographySystem.font(weight: .bold, size: .large))
                .foregroundColor(ColorSystem.Text.primary)
            
            HStack(spacing: 20) {
                animationDemo(name: "Standard", animation: AnimationSystem.Curve.standard(duration: AnimationSystem.Duration.medium))
                
                animationDemo(name: "Spring", animation: AnimationSystem.Curve.spring(duration: AnimationSystem.Duration.medium)())
                
                animationDemo(name: "Bouncy", animation: AnimationSystem.Curve.bouncySpring(duration: AnimationSystem.Duration.medium))
            }
            
            Button("Play Animations") {
                isAnimated = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isAnimated = true
                }
            }
            .padding()
            .background(ColorSystem.Brand.primary)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .background(ColorSystem.Background.secondary)
        .cornerRadius(12)
    }
    
    private func animationDemo(name: String, animation: Animation) -> some View {
        VStack {
            Circle()
                .fill(ColorSystem.Brand.primary)
                .frame(width: 50, height: 50)
                .offset(y: isAnimated ? 0 : 100)
                .opacity(isAnimated ? 1 : 0)
                .animation(isAnimated ? animation : nil, value: isAnimated)
            
            Text(name)
                .font(TypographySystem.font(weight: .medium, size: .xSmall))
                .foregroundColor(ColorSystem.Text.secondary)
        }
    }
    
    private var componentShowcase: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Components")
                .font(TypographySystem.font(weight: .bold, size: .large))
                .foregroundColor(ColorSystem.Text.primary)
            
            Text("Badges")
                .font(TypographySystem.font(weight: .medium, size: .medium))
                .foregroundColor(ColorSystem.Text.secondary)
            
            HStack(spacing: 12) {
                FOMOBadge("STANDARD", style: .standard)
                FOMOBadge("ACCENT", style: .accent)
                FOMOBadge("FEATURED", style: .featured)
                FOMOBadge("OUTLINE", style: .outline)
            }
            
            Text("Animated Badge")
                .font(TypographySystem.font(weight: .medium, size: .medium))
                .foregroundColor(ColorSystem.Text.secondary)
            
            FOMOBadge("NEW", style: .accent, isAnimated: true)
        }
        .padding()
        .background(ColorSystem.Background.secondary)
        .cornerRadius(12)
    }
}

#if DEBUG
struct DesignShowcase_Previews: PreviewProvider {
    static var previews: some View {
        DesignShowcase()
    }
}
#endif 