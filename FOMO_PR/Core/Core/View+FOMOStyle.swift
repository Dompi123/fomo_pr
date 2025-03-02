import SwiftUI

public extension View {
    func fomoTextStyle(_ font: Font) -> some View {
        self.font(font)
    }
    
    func fomoShadow() -> some View {
        self.shadow(color: FOMOTheme.Shadow.medium, radius: 4, x: 0, y: 2)
    }
    
    func fomoCard() -> some View {
        self
            .padding(FOMOTheme.Spacing.medium)
            .background(FOMOTheme.Colors.surface)
            .cornerRadius(FOMOTheme.Radius.medium)
            .fomoShadow()
    }
    
    func fomoButton(style: FOMOButtonStyle = .primary) -> some View {
        self
            .font(FOMOTheme.Typography.button)
            .foregroundColor(style == .primary ? .white : FOMOTheme.Colors.primary)
            .padding(.horizontal, FOMOTheme.Spacing.medium)
            .padding(.vertical, FOMOTheme.Spacing.small)
            .background(style == .primary ? FOMOTheme.Colors.primary : .clear)
            .cornerRadius(FOMOTheme.Radius.small)
            .overlay(
                RoundedRectangle(cornerRadius: FOMOTheme.Radius.small)
                    .stroke(style == .primary ? Color.clear : FOMOTheme.Colors.primary, lineWidth: 1)
            )
    }
}

public enum FOMOButtonStyle {
    case primary
    case secondary
} 