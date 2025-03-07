import SwiftUI

/// Comprehensive animation system for FOMO app
public enum AnimationSystem {
    // MARK: - Animation Durations
    public enum Duration {
        /// Very quick animations (100ms)
        public static let veryFast: Double = 0.1
        
        /// Quick animations (200ms)
        public static let fast: Double = 0.2
        
        /// Standard animation speed (300ms)
        public static let standard: Double = 0.3
        
        /// Medium length animations (500ms)
        public static let medium: Double = 0.5
        
        /// Slow animations (800ms)
        public static let slow: Double = 0.8
        
        /// Very slow animations (1200ms) 
        public static let verySlow: Double = 1.2
    }
    
    // MARK: - Animation Curves
    public enum Curve {
        /// Linear animation curve (constant speed)
        public static let linear = SwiftUI.Animation.linear
        
        /// Default ease-in-out curve for standard transitions
        public static let standard = SwiftUI.Animation.easeInOut
        
        /// Ease-in curve for elements exiting
        public static let easeIn = SwiftUI.Animation.easeIn
        
        /// Ease-out curve for elements entering
        public static let easeOut = SwiftUI.Animation.easeOut
        
        /// Spring animation for natural, bouncy transitions
        public static let spring = { (duration: Double, response: Double = 0.55, dampingFraction: Double = 0.825) in
            SwiftUI.Animation.spring(response: response, dampingFraction: dampingFraction, blendDuration: duration)
        }
        
        /// Extra bouncy spring animation for playful elements
        public static let bouncySpring = { (duration: Double) in
            SwiftUI.Animation.spring(response: 0.6, dampingFraction: 0.6, blendDuration: duration)
        }
    }
    
    // MARK: - Predefined Animations
    
    /// Very quick standard animation
    public static let veryFast = Curve.standard(duration: Duration.veryFast)
    
    /// Quick standard animation 
    public static let fast = Curve.standard(duration: Duration.fast)
    
    /// Standard animation for most transitions
    public static let standard = Curve.standard(duration: Duration.standard)
    
    /// Medium-length standard animation
    public static let medium = Curve.standard(duration: Duration.medium)
    
    /// Spring animation for interactive elements
    public static let interactiveSpring = Curve.spring(Duration.standard)
    
    /// Pronounced spring animation for important transitions
    public static let emphasizedSpring = Curve.spring(Duration.medium, 0.5, 0.75)
    
    /// Linear animation for progress indicators
    public static let linear = Curve.linear(duration: Duration.standard)
    
    // MARK: - Predefined Animation Sequences
    
    /// Fade in animation
    public static let fadeIn = SwiftUI.Animation.easeIn(duration: Duration.fast)
    
    /// Fade out animation
    public static let fadeOut = SwiftUI.Animation.easeOut(duration: Duration.fast)
    
    /// Slide in from bottom animation
    public static let slideInBottom = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.7)
    
    /// Slide out to bottom animation
    public static let slideOutBottom = SwiftUI.Animation.easeInOut(duration: Duration.fast)
    
    /// Pop animation for feedback
    public static let pop = SwiftUI.Animation.spring(response: 0.28, dampingFraction: 0.68)
}

// MARK: - View Extensions for Animations
public extension View {
    /// Apply the standard appear animation
    func animateAppear() -> some View {
        self.transition(.opacity
            .combined(with: .scale(scale: 0.95, anchor: .center))
            .animation(.easeOut(duration: AnimationSystem.Duration.fast))
        )
    }
    
    /// Apply the standard disappear animation
    func animateDisappear() -> some View {
        self.transition(.opacity
            .combined(with: .scale(scale: 0.95, anchor: .center))
            .animation(.easeIn(duration: AnimationSystem.Duration.fast))
        )
    }
    
    /// Apply a slide in from bottom animation
    func animateSlideUp() -> some View {
        self.transition(.move(edge: .bottom).combined(with: .opacity)
            .animation(AnimationSystem.slideInBottom)
        )
    }
    
    /// Apply a slide down animation
    func animateSlideDown() -> some View {
        self.transition(.move(edge: .top).combined(with: .opacity)
            .animation(AnimationSystem.slideOutBottom)
        )
    }
    
    /// Apply a bounce effect when value changes
    func animateBounce<Value: Equatable>(on value: Value) -> some View {
        self.modifier(BounceEffectModifier(value: value))
    }
    
    /// Apply a pulse effect
    func animatePulse(autoRepeat: Bool = false) -> some View {
        self.modifier(PulseEffectModifier(autoRepeat: autoRepeat))
    }
    
    /// Apply a shimmer effect (for loading states)
    func animateShimmer() -> some View {
        self.modifier(ShimmerEffectModifier())
    }
}

// MARK: - Animation Modifiers

/// Modifier that applies a bounce effect when a value changes
public struct BounceEffectModifier<Value: Equatable>: ViewModifier {
    let value: Value
    @State private var bouncing = false
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(bouncing ? 1.03 : 1.0)
            .onChange(of: value) { _ in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    bouncing = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        bouncing = false
                    }
                }
            }
    }
}

/// Modifier that applies a pulsing effect
public struct PulseEffectModifier: ViewModifier {
    let autoRepeat: Bool
    @State private var pulsing = false
    
    public func body(content: Content) -> some View {
        content
            .scaleEffect(pulsing ? 1.05 : 0.98)
            .opacity(pulsing ? 1.0 : 0.8)
            .onAppear {
                withAnimation(Animation.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    pulsing = autoRepeat
                }
            }
            .onTapGesture {
                if !autoRepeat {
                    withAnimation(Animation.easeInOut(duration: 0.8)) {
                        pulsing = true
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(Animation.easeInOut(duration: 0.8)) {
                            pulsing = false
                        }
                    }
                }
            }
    }
}

/// Modifier that applies a shimmer effect for loading states
public struct ShimmerEffectModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: phase - 0.3),
                            .init(color: .white.opacity(0.3), location: phase),
                            .init(color: .clear, location: phase + 0.3)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .mask(content)
                    .blendMode(.screen)
                }
            )
            .onAppear {
                withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1.0
                }
            }
    }
}

// MARK: - Preview
struct AnimationSystem_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 25) {
            Text("Animation System").title1()
            
            // Bounce Effect
            Group {
                Text("Bounce Effect").title3()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                @State var bounceValue = 0
                
                Button("Trigger Bounce") {
                    bounceValue += 1
                }
                .padding()
                .foregroundColor(.white)
                .background(ColorSystem.Brand.primary)
                .cornerRadius(FOMOTheme.Radius.medium)
                .animateBounce(on: bounceValue)
            }
            
            // Pulse Effect
            Group {
                Text("Pulse Effect").title3()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                HStack(spacing: 20) {
                    Text("Auto Pulse")
                        .padding()
                        .background(ColorSystem.Brand.secondary)
                        .cornerRadius(FOMOTheme.Radius.medium)
                        .animatePulse(autoRepeat: true)
                    
                    Text("Tap to Pulse")
                        .padding()
                        .background(ColorSystem.Brand.secondary)
                        .cornerRadius(FOMOTheme.Radius.medium)
                        .animatePulse(autoRepeat: false)
                }
            }
            
            // Shimmer Effect
            Group {
                Text("Shimmer Effect").title3()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                Text("Loading Content...")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(FOMOTheme.Radius.medium)
                    .animateShimmer()
            }
            
            // Enter/Exit Animations
            Group {
                Text("Enter/Exit Animations").title3()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                
                @State var showContent = false
                
                Button("Toggle Content") {
                    withAnimation {
                        showContent.toggle()
                    }
                }
                .padding()
                .foregroundColor(.white)
                .background(ColorSystem.Brand.primary)
                .cornerRadius(FOMOTheme.Radius.medium)
                
                if showContent {
                    Text("This content appears and disappears with animations!")
                        .padding()
                        .background(ColorSystem.Background.secondary)
                        .cornerRadius(FOMOTheme.Radius.medium)
                        .animateAppear()
                }
            }
        }
        .padding()
        .withTheme()
    }
} 