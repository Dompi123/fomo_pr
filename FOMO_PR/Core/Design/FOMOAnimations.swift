import SwiftUI

public enum FOMOAnimations {
    // MARK: - Transitions
    public enum Transitions {
        public static let slide = AnyTransition.asymmetric(
            insertion: .move(edge: .trailing),
            removal: .move(edge: .leading)
        )
        
        public static let fade = AnyTransition.opacity
            .animation(.easeInOut(duration: 0.3))
        
        public static let scale = AnyTransition.scale
            .combined(with: .opacity)
            .animation(.spring(response: 0.3, dampingFraction: 0.7))
    }
    
    // MARK: - Loading
    public struct LoadingView: View {
        @State private var isAnimating = false
        
        public init() {}
        
        public var body: some View {
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(FOMOTheme.Colors.primary, lineWidth: 2)
                .frame(width: 24, height: 24)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .onAppear {
                    withAnimation(
                        Animation
                            .linear(duration: 1)
                            .repeatForever(autoreverses: false)
                    ) {
                        isAnimating = true
                    }
                }
        }
    }
    
    // MARK: - Pulse
    public struct PulseView: View {
        @State private var isAnimating = false
        private let color: Color
        
        public init(color: Color = FOMOTheme.Colors.primary) {
            self.color = color
        }
        
        public var body: some View {
            Circle()
                .fill(color)
                .scaleEffect(isAnimating ? 1.2 : 0.8)
                .opacity(isAnimating ? 0.5 : 1)
                .animation(
                    Animation
                        .easeInOut(duration: 1)
                        .repeatForever(autoreverses: true),
                    value: isAnimating
                )
                .onAppear {
                    isAnimating = true
                }
        }
    }
    
    // MARK: - Shake
    public struct ShakeEffect: GeometryEffect {
        var amount: CGFloat = 10
        var shakesPerUnit = 3
        var animatableData: CGFloat
        
        public init(amount: CGFloat = 10, shakesPerUnit: Int = 3, animatableData: CGFloat) {
            self.amount = amount
            self.shakesPerUnit = shakesPerUnit
            self.animatableData = animatableData
        }
        
        public func effectValue(size: CGSize) -> ProjectionTransform {
            ProjectionTransform(CGAffineTransform(translationX:
                amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
                y: 0))
        }
    }
    
    // MARK: - View Extensions
    public extension View {
        func shake(with amount: CGFloat) -> some View {
            modifier(ShakeEffect(amount: amount, animatableData: amount))
        }
        
        func slideTransition() -> some View {
            transition(Transitions.slide)
        }
        
        func fadeTransition() -> some View {
            transition(Transitions.fade)
        }
        
        func scaleTransition() -> some View {
            transition(Transitions.scale)
        }
    }
}

// MARK: - Preview Extensions
#if DEBUG
struct FOMOAnimations_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: FOMOTheme.Spacing.large) {
            FOMOAnimations.LoadingView()
            
            FOMOAnimations.PulseView()
                .frame(width: 50, height: 50)
            
            Text("Shake Me!")
                .font(FOMOTheme.Typography.headline)
                .shake(with: 5)
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
} 