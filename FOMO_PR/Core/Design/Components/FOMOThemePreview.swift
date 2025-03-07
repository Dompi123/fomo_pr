import SwiftUI

/// A component that displays all theme tokens for visual inspection.
/// Use this in SwiftUI previews to visualize the design system.
public struct FOMOThemePreview: View {
    private let showColors: Bool
    private let showTypography: Bool
    private let showSpacing: Bool
    private let showComponents: Bool
    
    public init(
        showColors: Bool = true,
        showTypography: Bool = true,
        showSpacing: Bool = true,
        showComponents: Bool = true
    ) {
        self.showColors = showColors
        self.showTypography = showTypography
        self.showSpacing = showSpacing
        self.showComponents = showComponents
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.large) {
                if showColors {
                    colorsSection
                }
                
                if showTypography {
                    typographySection
                }
                
                if showSpacing {
                    spacingSection
                }
                
                if showComponents {
                    componentsSection
                }
            }
            .padding(FOMOTheme.Spacing.medium)
            .background(FOMOTheme.Colors.background)
        }
        .background(FOMOTheme.Colors.background)
    }
    
    // MARK: - Color Section
    
    private var colorsSection: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
            sectionHeader("Colors")
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: FOMOTheme.Spacing.medium) {
                colorItem("Primary", FOMOTheme.Colors.primary)
                colorItem("Secondary", FOMOTheme.Colors.secondary)
                colorItem("Background", FOMOTheme.Colors.background)
                colorItem("Surface", FOMOTheme.Colors.surface)
                colorItem("Text", FOMOTheme.Colors.text)
                colorItem("Text Secondary", FOMOTheme.Colors.textSecondary)
                colorItem("Accent", FOMOTheme.Colors.accent)
                colorItem("Success", FOMOTheme.Colors.success)
                colorItem("Warning", FOMOTheme.Colors.warning)
                colorItem("Error", FOMOTheme.Colors.error)
            }
        }
    }
    
    private func colorItem(_ name: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
            Rectangle()
                .fill(color)
                .frame(height: 60)
                .cornerRadius(FOMOTheme.Radius.small)
            
            Text(name)
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.text)
        }
    }
    
    // MARK: - Typography Section
    
    private var typographySection: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
            sectionHeader("Typography")
            
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                typographyItem("Display", FOMOTheme.Typography.display)
                typographyItem("Headline Large", FOMOTheme.Typography.headlineLarge)
                typographyItem("Headline Medium", FOMOTheme.Typography.headlineMedium)
                typographyItem("Headline Small", FOMOTheme.Typography.headlineSmall)
                typographyItem("Body Large", FOMOTheme.Typography.bodyLarge)
                typographyItem("Body Regular", FOMOTheme.Typography.bodyRegular)
                typographyItem("Body Small", FOMOTheme.Typography.bodySmall)
                typographyItem("Caption 1", FOMOTheme.Typography.caption1)
                typographyItem("Caption 2", FOMOTheme.Typography.caption2)
            }
        }
    }
    
    private func typographyItem(_ name: String, _ font: Font) -> some View {
        HStack(alignment: .center, spacing: FOMOTheme.Spacing.medium) {
            Text(name)
                .frame(width: 120, alignment: .leading)
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            Text("The quick brown fox")
                .font(font)
                .foregroundColor(FOMOTheme.Colors.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(FOMOTheme.Spacing.small)
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Radius.small)
    }
    
    // MARK: - Spacing Section
    
    private var spacingSection: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
            sectionHeader("Spacing")
            
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                spacingItem("XXSmall", FOMOTheme.Spacing.xxSmall)
                spacingItem("XSmall", FOMOTheme.Spacing.xSmall)
                spacingItem("Small", FOMOTheme.Spacing.small)
                spacingItem("Medium", FOMOTheme.Spacing.medium)
                spacingItem("Large", FOMOTheme.Spacing.large)
                spacingItem("XLarge", FOMOTheme.Spacing.xLarge)
            }
        }
    }
    
    private func spacingItem(_ name: String, _ spacing: CGFloat) -> some View {
        HStack(alignment: .center, spacing: FOMOTheme.Spacing.medium) {
            Text(name)
                .frame(width: 80, alignment: .leading)
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            Rectangle()
                .fill(FOMOTheme.Colors.primary)
                .frame(width: spacing, height: 40)
            
            Text("\(Int(spacing))")
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(FOMOTheme.Spacing.small)
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Radius.small)
    }
    
    // MARK: - Components Section
    
    private var componentsSection: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
            sectionHeader("Components")
            
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
                componentSection("Buttons", buttonsPreview)
                componentSection("Cards", cardsPreview)
                componentSection("List Rows", listRowsPreview)
            }
        }
    }
    
    private var buttonsPreview: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
            FOMOButton("Primary Button", style: .primary) {}
            FOMOButton("Secondary Button", style: .secondary) {}
            FOMOButton("Text Button", style: .text) {}
            FOMOButton("Disabled Button", style: .primary, isEnabled: false) {}
        }
        .padding(FOMOTheme.Spacing.medium)
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Radius.medium)
    }
    
    private var cardsPreview: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
            FOMOCard {
                Text("Standard Card")
                    .font(FOMOTheme.Typography.headlineSmall)
            }
            
            FOMOCard(padding: .small, backgroundColor: FOMOTheme.Colors.primary.opacity(0.1)) {
                Text("Custom Card")
                    .font(FOMOTheme.Typography.bodyRegular)
            }
        }
    }
    
    private var listRowsPreview: some View {
        VStack(alignment: .leading, spacing: 0) {
            FOMOTitleRow(title: "Standard Row", subtitle: "With subtitle")
            
            FOMOTitleRow.withIcon(
                title: "Icon Row",
                subtitle: "With icon",
                icon: "star.fill",
                iconColor: FOMOTheme.Colors.warning
            )
            
            FOMOTitleRow.withDisclosure(
                title: "Disclosure Row",
                action: {}
            )
        }
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Radius.medium)
    }
    
    // MARK: - Helper Views
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(FOMOTheme.Typography.headlineMedium)
            .foregroundColor(FOMOTheme.Colors.text)
            .padding(.bottom, FOMOTheme.Spacing.small)
    }
    
    private func componentSection(_ title: String, _ content: some View) -> some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
            Text(title)
                .font(FOMOTheme.Typography.bodyLarge)
                .foregroundColor(FOMOTheme.Colors.text)
            
            content
        }
    }
}

#if DEBUG
struct FOMOThemePreview_Previews: PreviewProvider {
    static var previews: some View {
        FOMOThemePreview()
            .previewDisplayName("Full Preview")
        
        FOMOThemePreview(showColors: true, showTypography: false, showSpacing: false, showComponents: false)
            .previewDisplayName("Colors Only")
        
        FOMOThemePreview(showColors: false, showTypography: true, showSpacing: false, showComponents: false)
            .previewDisplayName("Typography Only")
        
        FOMOThemePreview(showColors: false, showTypography: false, showSpacing: false, showComponents: true)
            .previewDisplayName("Components Only")
    }
} 