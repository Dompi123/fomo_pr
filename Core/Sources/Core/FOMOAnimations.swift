import Foundation
import SwiftUI

// MARK: - Animations
public enum FOMOAnimations {
    public static let standard = Animation.easeInOut(duration: 0.3)
    public static let slow = Animation.easeInOut(duration: 0.5)
    public static let fast = Animation.easeInOut(duration: 0.2)
    
    public static func spring(response: Double = 0.55, dampingFraction: Double = 0.825) -> Animation {
        return Animation.spring(response: response, dampingFraction: dampingFraction)
    }
} 