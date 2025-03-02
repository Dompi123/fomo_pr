import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

public enum FOMOAnimations {
    public static let smooth = Animation.easeInOut(duration: 0.3)
    public static let quick = Animation.easeInOut(duration: 0.2)
    public static let slow = Animation.easeInOut(duration: 0.5)
    
    public static let spring = Animation.spring(
        response: 0.3,
        dampingFraction: 0.6,
        blendDuration: 0.2
    )
    
    public static let springQuick = Animation.spring(
        response: 0.2,
        dampingFraction: 0.5,
        blendDuration: 0.1
    )
    
    public static let springBouncy = Animation.spring(
        response: 0.4,
        dampingFraction: 0.4,
        blendDuration: 0.2
    )
}

// MARK: - Animation Modifiers
struct SlideTransition: ViewModifier {
    let isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .offset(x: isPresented ? 0 : getScreenWidth())
            .animation(FOMOAnimations.spring, value: isPresented)
    }
    
    private func getScreenWidth() -> CGFloat {
        #if canImport(UIKit)
        return UIScreen.main.bounds.width
        #else
        return 500 // Default value for macOS
        #endif
    }
}

struct FadeTransition: ViewModifier {
    let isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .opacity(isPresented ? 1 : 0)
            .animation(FOMOAnimations.smooth, value: isPresented)
    }
}

// MARK: - View Extensions
extension View {
    func slideTransition(isPresented: Bool) -> some View {
        modifier(SlideTransition(isPresented: isPresented))
    }
    
    func fadeTransition(isPresented: Bool) -> some View {
        modifier(FadeTransition(isPresented: isPresented))
    }
} 