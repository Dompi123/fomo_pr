# FOMO Design System

Welcome to the FOMO Design System documentation. This design system ensures visual consistency, improves development efficiency, and provides a better user experience across the FOMO app.

## Quick Start

To use the design system in your SwiftUI views:

```swift
import SwiftUI

struct MyView: View {
    var body: some View {
        VStack(spacing: FOMOTheme.Spacing.medium) {
            Text("Headline")
                .font(FOMOTheme.Typography.headlineMedium)
                .foregroundColor(FOMOTheme.Colors.text)
                
            FOMOButton("Primary Action", style: .primary) {
                // Action here
            }
            
            FOMOCard {
                Text("Card Content")
                    .font(FOMOTheme.Typography.bodyRegular)
            }
        }
        .padding(FOMOTheme.Spacing.medium)
        .background(FOMOTheme.Colors.background)
    }
}
```

## Design System Components

The design system consists of:

1. **Design Tokens** (`FOMOTheme.swift`)
   - Colors, typography, spacing, radius values
   - Use these for all styling to maintain consistency

2. **View Modifiers** (`FOMOThemeModifiers.swift`)
   - Convenience modifiers like `.fomoHeadline()`, `.fomoCard()`
   - Use these instead of chaining multiple modifiers

3. **UI Components** (in `Components/` directory)
   - `FOMOButton` - Standard buttons with multiple styles
   - `FOMOCard` - Card containers with consistent styling
   - `FOMOListRow` - Consistent list items

4. **Testing & Preview Tools**
   - `FOMOThemePreview` - Display all design tokens and components
   - `BeforeAfterGallery` - Compare styling before and after design system
   - `ThemeVisualTester` - Visual regression testing tool

For complete documentation, see [FOMODesignSystem.md](FOMODesignSystem.md).

## Compliance Tools

To help ensure consistent use of the design system:

1. **SwiftLint Rules**
   - Custom rules to detect direct styling
   - Run `swiftlint` to see violations

2. **Migration Script**
   - `scripts/migrate_theme.swift` - Automatically convert direct styling
   - Creates `.themed.swift` files for review

3. **Compliance Check**
   - `scripts/check_design_system_usage.sh` - Check compliance percentage
   - `scripts/ci_design_system_check.sh` - For CI/CD pipelines

## Best Practices

1. **Always use design tokens**
   - Instead of `.font(.headline)`, use `.font(FOMOTheme.Typography.headlineMedium)`
   - Instead of `.foregroundColor(.red)`, use `.foregroundColor(FOMOTheme.Colors.error)`

2. **Use component modifiers**
   - Instead of individual styling, use `.fomoHeadline()`, `.fomoCard()`, etc.

3. **Use semantic naming**
   - Use `error` instead of `red`, `success` instead of `green`
   - Choose tokens based on meaning, not appearance

4. **Create feature-specific extensions**
   - When needed, create feature-specific extensions like `.venueNameStyle()`

5. **Test visual consistency**
   - Use the `BeforeAfterGallery` to visualize changes
   - Run checks for design system compliance

## How to Contribute

1. New components should:
   - Use only FOMOTheme tokens for styling
   - Be reusable across the app
   - Include proper documentation
   - Include preview examples

2. To modify design tokens:
   - Update the appropriate section in FOMOTheme.swift
   - Use the visual testing tools to verify changes
   - Update documentation as needed

## Contact

For questions about the design system, contact the UI/UX team.

## Troubleshooting

Common issues:

1. **SwiftLint compliance warnings** - Use the migration script to fix
2. **Inconsistent appearance** - Ensure you're using theme tokens, not direct styling
3. **Missing tokens** - Request additions through the UI/UX team 