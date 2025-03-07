import SwiftUI

// MARK: - Core Theme Extensions
public extension View {
    // MARK: - Typography Modifiers
    
    /// Apply headline style to text
    func fomoHeadline() -> some View {
        self.font(FOMOTheme.Typography.headlineMedium)
            .foregroundColor(FOMOTheme.Colors.text)
    }
    
    /// Apply title style to text
    func fomoTitle() -> some View {
        self.font(FOMOTheme.Typography.headlineLarge)
            .foregroundColor(FOMOTheme.Colors.text)
    }
    
    /// Apply subtitle style to text
    func fomoSubtitle() -> some View {
        self.font(FOMOTheme.Typography.headlineSmall)
            .foregroundColor(FOMOTheme.Colors.text)
    }
    
    /// Apply body text style
    func fomoBodyText() -> some View {
        self.font(FOMOTheme.Typography.bodyRegular)
            .foregroundColor(FOMOTheme.Colors.text)
    }
    
    /// Apply caption style to text
    func fomoCaption() -> some View {
        self.font(FOMOTheme.Typography.caption1)
            .foregroundColor(FOMOTheme.Colors.textSecondary)
    }
    
    // MARK: - Component Modifiers
    
    /// Apply primary button styling
    func fomoPrimaryButton() -> some View {
        self.padding(.horizontal, FOMOTheme.Spacing.medium)
            .padding(.vertical, FOMOTheme.Spacing.small)
            .background(FOMOTheme.Colors.primary)
            .foregroundColor(.white)
            .cornerRadius(FOMOTheme.Radius.medium)
    }
    
    /// Apply secondary button styling
    func fomoSecondaryButton() -> some View {
        self.padding(.horizontal, FOMOTheme.Spacing.medium)
            .padding(.vertical, FOMOTheme.Spacing.small)
            .background(FOMOTheme.Colors.surface)
            .foregroundColor(FOMOTheme.Colors.text)
            .cornerRadius(FOMOTheme.Radius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: FOMOTheme.Radius.medium)
                    .stroke(FOMOTheme.Colors.primary, lineWidth: 1)
            )
    }
    
    /// Apply card styling
    func fomoCard() -> some View {
        self.padding(FOMOTheme.Spacing.medium)
            .background(FOMOTheme.Colors.surface)
            .cornerRadius(FOMOTheme.Radius.medium)
            .shadow(color: FOMOTheme.Shadow.medium, radius: 4, x: 0, y: 2)
    }
    
    /// Apply list item styling
    func fomoListItem() -> some View {
        self.padding(FOMOTheme.Spacing.medium)
            .background(FOMOTheme.Colors.surface)
            .cornerRadius(FOMOTheme.Radius.small)
    }
    
    // MARK: - Layout Modifiers
    
    /// Apply standard content padding
    func fomoContentPadding() -> some View {
        self.padding(FOMOTheme.Spacing.medium)
    }
    
    /// Apply section padding with divider
    func fomoSectionStyle() -> some View {
        self.padding(.vertical, FOMOTheme.Spacing.large)
            .padding(.horizontal, FOMOTheme.Spacing.medium)
    }
}

// MARK: - Component-Specific Modifiers
public extension View {
    /// Venue list item styling
    func venueListItemStyle() -> some View {
        self.padding(.vertical, FOMOTheme.Spacing.small)
    }
    
    /// Venue name styling
    func venueNameStyle() -> some View {
        self.font(FOMOTheme.Typography.headline)
            .foregroundColor(FOMOTheme.Colors.text)
    }
    
    /// Venue description styling
    func venueDescriptionStyle() -> some View {
        self.font(FOMOTheme.Typography.subheadline)
            .foregroundColor(FOMOTheme.Colors.textSecondary)
            .lineLimit(2)
    }
    
    /// Drink list item styling
    func drinkListItemStyle() -> some View {
        self.padding(.vertical, FOMOTheme.Spacing.small)
    }
    
    /// Drink name styling
    func drinkNameStyle() -> some View {
        self.font(FOMOTheme.Typography.headline)
            .foregroundColor(FOMOTheme.Colors.text)
    }
    
    /// Price styling
    func priceStyle() -> some View {
        self.font(FOMOTheme.Typography.bodyLarge)
            .foregroundColor(FOMOTheme.Colors.accent)
    }
} 