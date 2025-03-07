# FOMO Design System Refactoring Plan

## Current Status

Based on our validation script, we have significant work remaining to fully implement the design system across the app:

- 200 instances of direct font usage
- 158 instances of direct color usage
- 221 instances of direct padding usage
- 54 instances of direct corner radius usage
- Overall design system compliance: 34%

## High-Priority Files

The following files should be refactored next:

1. `DrinkMenuView.swift` - Multiple instances of direct styling
2. `CheckoutView.swift` - Direct corner radius and styling
3. Any remaining core UI components not yet refactored

## Refactoring Strategy

### Phase 1: High-Priority Screens (Completed)
- ✅ VenueListView.swift
- ✅ VenueDetailView.swift
- ✅ PaywallView.swift
- ✅ ProfileView.swift
- ✅ PassesView.swift

### Phase 2: Secondary Screens
- ⬜️ DrinkMenuView.swift
- ⬜️ CheckoutView.swift
- ⬜️ OrderHistoryView.swift
- ⬜️ NotificationsView.swift
- ⬜️ SettingsView.swift

### Phase 3: Reusable Components
- ⬜️ Common buttons
- ⬜️ Cards
- ⬜️ List rows
- ⬜️ Form elements

### Phase 4: Finalization
- ⬜️ Run final validation
- ⬜️ Fix any remaining issues
- ⬜️ Document exceptions (if any)

## Common Styling Patterns to Refactor

### Font Usage

Replace:
```swift
.font(.title)
.font(.headline)
.font(.subheadline)
.font(.body)
.font(.caption)
.font(.system(size: 24))
```

With:
```swift
.font(FOMOTheme.Typography.title1)
.font(FOMOTheme.Typography.headline)
.font(FOMOTheme.Typography.subheadline)
.font(FOMOTheme.Typography.body)
.font(FOMOTheme.Typography.caption1)
```

Or better, with semantic modifiers:
```swift
.fomoTitle1Style()
.fomoHeadlineStyle()
.fomoSubheadlineStyle()
.fomoBodyStyle()
.fomoCaptionStyle()
```

### Color Usage

Replace:
```swift
.foregroundColor(.blue)
.foregroundColor(.secondary)
.foregroundColor(.gray)
.background(Color.white)
.background(Color.gray.opacity(0.1))
```

With:
```swift
.foregroundColor(FOMOTheme.Colors.primary)
.foregroundColor(FOMOTheme.Colors.textSecondary)
.foregroundColor(FOMOTheme.Colors.textSecondary)
.background(FOMOTheme.Colors.surface)
.background(FOMOTheme.Colors.surface.opacity(0.1))
```

### Padding Usage

Replace:
```swift
.padding()
.padding(.vertical)
.padding(.horizontal)
.padding(16)
.padding(.vertical, 8)
```

With:
```swift
.padding(FOMOTheme.Spacing.medium)
.padding(.vertical, FOMOTheme.Spacing.medium)
.padding(.horizontal, FOMOTheme.Spacing.medium)
.padding(FOMOTheme.Spacing.medium)
.padding(.vertical, FOMOTheme.Spacing.small)
```

### Corner Radius Usage

Replace:
```swift
.cornerRadius(12)
.cornerRadius(8)
```

With:
```swift
.cornerRadius(FOMOTheme.Radius.medium)
.cornerRadius(FOMOTheme.Radius.small)
```

Or better, with the modifier:
```swift
.fomoCornerRadius(FOMOTheme.Radius.medium)
.fomoCornerRadius(FOMOTheme.Radius.small)
```

## Refactoring Instructions

1. **Fonts**: Replace all direct font usage with appropriate tokens from `FOMOTheme.Typography` or semantic modifiers like `.fomoHeadlineStyle()`.

2. **Colors**: Replace all direct color usage with tokens from `FOMOTheme.Colors`.

3. **Padding**: Replace all direct padding values with tokens from `FOMOTheme.Spacing`.

4. **Corner Radius**: Replace all direct corner radius values with tokens from `FOMOTheme.Radius` or use the `.fomoCornerRadius()` modifier.

5. **Create Domain-Specific Extensions**: For screens with unique styling needs, create domain-specific extensions similar to `.paywallHeadingStyle()`.

## Testing Guidelines

1. Build and run the app after each file is refactored
2. Verify UI correctness on multiple device sizes
3. Check for visual regressions
4. Ensure all interactive elements still work correctly

## SwiftLint Rules

Once we reach at least 80% compliance, we should implement SwiftLint rules to prevent new direct styling:

```yaml
custom_rules:
  direct_font_usage:
    name: "Direct Font Usage"
    regex: '\.font\(\.(title|headline|subheadline|body|caption)|\.font\(\.system'
    message: "Use FOMOTheme.Typography tokens instead of direct font usage"
    severity: warning
    
  direct_color_usage:
    name: "Direct Color Usage"
    regex: '\.foregroundColor\(\.(primary|secondary|blue|red|green|gray|black|white)\)|\.background\(Color\.'
    message: "Use FOMOTheme.Colors tokens instead of direct color usage"
    severity: warning
    
  direct_padding_usage:
    name: "Direct Padding Usage"
    regex: '\.padding\((\d+)\)'
    message: "Use FOMOTheme.Spacing tokens instead of direct padding values"
    severity: warning
    
  direct_corner_radius_usage:
    name: "Direct Corner Radius Usage"
    regex: '\.cornerRadius\((\d+)\)'
    message: "Use FOMOTheme.Radius tokens or .fomoCornerRadius() instead of direct corner radius values"
    severity: warning
```

## Timeline

- Week 1: Complete Phase 2 (Secondary Screens)
- Week 2: Complete Phase 3 (Reusable Components)
- Week 3: Complete Phase 4 (Finalization)
- Week 4: Implement SwiftLint rules and documentation 