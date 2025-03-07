import SwiftUI
import FOMO_PR

// MARK: - Common FOMO Theme Extensions
// This file contains reusable styling extensions that can be used across the app

// MARK: - Basic View Extensions
public extension View {
    // MARK: - General Style Extensions
    func fomoBackground(_ color: Color = FOMOTheme.Colors.background) -> some View {
        self.background(color)
    }
    
    func fomoShadow(radius: CGFloat = 4, color: Color = FOMOTheme.Shadow.medium, x: CGFloat = 0, y: CGFloat = 2) -> some View {
        self.shadow(color: color, radius: radius, x: x, y: y)
    }
    
    func fomoCornerRadius(_ radius: CGFloat = FOMOTheme.Radius.medium) -> some View {
        self.cornerRadius(radius)
    }
    
    // MARK: - Text Style Extensions
    func fomoTextStyle(_ typography: Font) -> some View {
        self.font(typography)
    }
    
    func fomoHeadlineStyle() -> some View {
        self.font(FOMOTheme.Typography.headline)
    }
    
    func fomoTitle1Style() -> some View {
        self.font(FOMOTheme.Typography.title1)
    }
    
    func fomoTitle2Style() -> some View {
        self.font(FOMOTheme.Typography.title2)
    }
    
    func fomoBodyStyle() -> some View {
        self.font(FOMOTheme.Typography.body)
    }
    
    func fomoSubheadlineStyle() -> some View {
        self.font(FOMOTheme.Typography.subheadline)
            .foregroundColor(FOMOTheme.Colors.textSecondary)
    }
    
    func fomoCaptionStyle() -> some View {
        self.font(FOMOTheme.Typography.caption1)
    }
    
    // MARK: - Button Style Extensions
    func fomoPrimaryButtonStyle() -> some View {
        self.padding(.vertical, FOMOTheme.Spacing.small)
            .padding(.horizontal, FOMOTheme.Spacing.medium)
            .background(FOMOTheme.Colors.primary)
            .foregroundColor(FOMOTheme.Colors.text)
            .cornerRadius(FOMOTheme.Radius.medium)
    }
    
    func fomoSecondaryButtonStyle() -> some View {
        self.padding(.vertical, FOMOTheme.Spacing.small)
            .padding(.horizontal, FOMOTheme.Spacing.medium)
            .background(FOMOTheme.Colors.surface)
            .foregroundColor(FOMOTheme.Colors.primary)
            .cornerRadius(FOMOTheme.Radius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: FOMOTheme.Radius.medium)
                    .stroke(FOMOTheme.Colors.primary, lineWidth: 1)
            )
    }
    
    // MARK: - Card Style Extensions
    func fomoCardStyle() -> some View {
        self.padding(FOMOTheme.Spacing.medium)
            .background(FOMOTheme.Colors.surface)
            .cornerRadius(FOMOTheme.Radius.medium)
            .shadow(color: FOMOTheme.Shadow.medium, radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Tag Style Extensions
    func fomoTagStyle() -> some View {
        self.font(FOMOTheme.Typography.caption1)
            .padding(.horizontal, FOMOTheme.Spacing.small)
            .padding(.vertical, FOMOTheme.Spacing.xxSmall)
            .background(FOMOTheme.Colors.primary.opacity(0.1))
            .foregroundColor(FOMOTheme.Colors.primary)
            .cornerRadius(FOMOTheme.Radius.small)
    }
    
    // MARK: - Image Style Extensions
    func fomoImageStyle(width: CGFloat = 60, height: CGFloat = 60) -> some View {
        self.frame(width: width, height: height)
            .cornerRadius(FOMOTheme.Radius.small)
    }
    
    func fomoPlaceholderStyle(width: CGFloat = 60, height: CGFloat = 60) -> some View {
        self.fill(FOMOTheme.Colors.surface)
            .frame(width: width, height: height)
            .cornerRadius(FOMOTheme.Radius.small)
    }
}

// MARK: - Venue Related Extensions
public extension View {
    // Venue List Item Styling
    func venueListItemStyle() -> some View {
        self.padding(.vertical, FOMOTheme.Spacing.small)
    }
    
    func venueNameStyle() -> some View {
        self.font(FOMOTheme.Typography.headline)
    }
    
    func venueDescriptionStyle() -> some View {
        self.font(FOMOTheme.Typography.subheadline)
            .foregroundColor(FOMOTheme.Colors.textSecondary)
            .lineLimit(2)
    }
    
    func venueRatingStyle() -> some View {
        self.foregroundColor(FOMOTheme.Colors.warning)
    }
    
    func venueAddressStyle() -> some View {
        self.font(FOMOTheme.Typography.caption1)
            .foregroundColor(FOMOTheme.Colors.textSecondary)
    }
    
    // Venue Detail Styling
    func venueTitleStyle() -> some View {
        self.font(FOMOTheme.Typography.title1)
            .fontWeight(.bold)
    }
    
    func venueSubtitleStyle() -> some View {
        self.font(FOMOTheme.Typography.subheadline)
            .foregroundColor(FOMOTheme.Colors.textSecondary)
    }
    
    func venueBodyStyle() -> some View {
        self.font(FOMOTheme.Typography.body)
    }
    
    func venueCaptionStyle() -> some View {
        self.font(FOMOTheme.Typography.caption1)
    }
    
    func venueActionButtonStyle(isEnabled: Bool = true) -> some View {
        self.frame(maxWidth: .infinity)
            .padding(.vertical, FOMOTheme.Spacing.small)
            .background(isEnabled ? FOMOTheme.Colors.primary : FOMOTheme.Colors.textSecondary)
            .foregroundColor(FOMOTheme.Colors.text)
            .cornerRadius(FOMOTheme.Radius.medium)
    }
    
    func venueTagStyle() -> some View {
        self.fomoTagStyle()
    }
}

// MARK: - Drink Related Extensions
public extension View {
    func drinkTitleStyle() -> some View {
        self.font(FOMOTheme.Typography.headline)
    }
    
    func drinkDescriptionStyle() -> some View {
        self.font(FOMOTheme.Typography.subheadline)
            .foregroundColor(FOMOTheme.Colors.textSecondary)
            .lineLimit(2)
    }
    
    func drinkPriceStyle() -> some View {
        self.font(FOMOTheme.Typography.subheadline)
            .foregroundColor(FOMOTheme.Colors.primary)
    }
    
    func drinkQuantityStyle() -> some View {
        self.font(FOMOTheme.Typography.headline)
            .foregroundColor(FOMOTheme.Colors.primary)
    }
    
    func drinkImageStyle() -> some View {
        self.fomoImageStyle()
    }
    
    func drinkPlaceholderStyle() -> some View {
        self.fomoPlaceholderStyle()
    }
    
    func drinkIconStyle() -> some View {
        self.font(.system(size: 30))
            .foregroundColor(FOMOTheme.Colors.textSecondary)
            .frame(width: 60, height: 60)
            .background(FOMOTheme.Colors.surface)
            .cornerRadius(FOMOTheme.Radius.small)
    }
    
    func drinkErrorIconStyle() -> some View {
        self.font(.system(size: 50))
            .foregroundColor(FOMOTheme.Colors.error)
            .padding(FOMOTheme.Spacing.medium)
    }
    
    func drinkEmptyIconStyle() -> some View {
        self.font(.system(size: 50))
            .foregroundColor(FOMOTheme.Colors.textSecondary)
            .padding(FOMOTheme.Spacing.medium)
    }
    
    func drinkButtonStyle() -> some View {
        self.buttonStyle(.bordered)
    }
}

// MARK: - Profile Related Extensions
public extension View {
    func profileHeadingStyle() -> some View {
        self.font(FOMOTheme.Typography.headline)
            .foregroundColor(FOMOTheme.Colors.text)
    }
    
    func profileSubheadingStyle() -> some View {
        self.font(FOMOTheme.Typography.subheadline)
            .foregroundColor(FOMOTheme.Colors.textSecondary)
    }
    
    func profileAvatarStyle(size: CGFloat = 60) -> some View {
        self.font(.system(size: size))
            .foregroundColor(FOMOTheme.Colors.primary)
    }
    
    func profileSectionStyle() -> some View {
        self.font(FOMOTheme.Typography.headline)
            .foregroundColor(FOMOTheme.Colors.textSecondary)
            .padding(.top, FOMOTheme.Spacing.medium)
    }
    
    func profileRowStyle() -> some View {
        self.padding(.vertical, FOMOTheme.Spacing.small)
    }
}

// MARK: - Passes Related Extensions
public extension View {
    func passesHeadingStyle() -> some View {
        self.font(FOMOTheme.Typography.title1)
            .fontWeight(.bold)
            .foregroundColor(FOMOTheme.Colors.text)
    }
    
    func passesSubheadingStyle() -> some View {
        self.font(FOMOTheme.Typography.subheadline)
            .foregroundColor(FOMOTheme.Colors.textSecondary)
    }
    
    func passesIconStyle(size: CGFloat = 60) -> some View {
        self.font(.system(size: size))
            .foregroundColor(FOMOTheme.Colors.textSecondary)
            .padding(FOMOTheme.Spacing.medium)
    }
    
    func passCardStyle() -> some View {
        self.padding(FOMOTheme.Spacing.medium)
            .background(FOMOTheme.Colors.surface)
            .cornerRadius(FOMOTheme.Radius.medium)
            .shadow(color: FOMOTheme.Shadow.medium, radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview
struct FOMOThemeExtensions_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: FOMOTheme.Spacing.medium) {
            // Text styles
            Text("Title 1").fomoTitle1Style()
            Text("Headline").fomoHeadlineStyle()
            Text("Body Text").fomoBodyStyle()
            Text("Subheadline").fomoSubheadlineStyle()
            Text("Caption").fomoCaptionStyle()
            
            // Button styles
            Button("Primary Button") {}.fomoPrimaryButtonStyle()
            Button("Secondary Button") {}.fomoSecondaryButtonStyle()
            
            // Tag
            Text("Tag").fomoTagStyle()
            
            // Card
            Text("Card Content").fomoCardStyle()
        }
        .padding()
        .fomoBackground()
    }
} 