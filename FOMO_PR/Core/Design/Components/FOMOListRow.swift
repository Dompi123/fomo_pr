import SwiftUI

/// A standardized list row component for use in lists and collections.
public struct FOMOListRow<Content: View>: View {
    private let content: Content
    private let showDivider: Bool
    private let padding: EdgeInsets
    
    /// Initialize a new FOMOListRow
    /// - Parameters:
    ///   - showDivider: Whether to show a divider at the bottom of the row
    ///   - padding: Custom padding to apply to the content
    ///   - content: Content to display inside the row
    public init(
        showDivider: Bool = true,
        padding: EdgeInsets? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.showDivider = showDivider
        self.padding = padding ?? EdgeInsets(
            top: FOMOTheme.Spacing.small,
            leading: FOMOTheme.Spacing.medium,
            bottom: FOMOTheme.Spacing.small,
            trailing: FOMOTheme.Spacing.medium
        )
        self.content = content()
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            content
                .padding(padding)
            
            if showDivider {
                Divider()
                    .background(FOMOTheme.Colors.textSecondary.opacity(0.2))
            }
        }
        .background(FOMOTheme.Colors.surface)
    }
}

/// A standardized list row with a title and optional subtitle and accessories.
public struct FOMOTitleRow: View {
    private let title: String
    private let subtitle: String?
    private let leadingAccessory: AnyView?
    private let trailingAccessory: AnyView?
    private let showDivider: Bool
    private let action: (() -> Void)?
    
    /// Initialize a new FOMOTitleRow
    /// - Parameters:
    ///   - title: The main text of the row
    ///   - subtitle: Optional secondary text to display below the title
    ///   - leadingAccessory: Optional view to display at the start of the row
    ///   - trailingAccessory: Optional view to display at the end of the row
    ///   - showDivider: Whether to show a divider at the bottom of the row
    ///   - action: Optional action to perform when the row is tapped
    public init(
        title: String,
        subtitle: String? = nil,
        leadingAccessory: AnyView? = nil,
        trailingAccessory: AnyView? = nil,
        showDivider: Bool = true,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingAccessory = leadingAccessory
        self.trailingAccessory = trailingAccessory
        self.showDivider = showDivider
        self.action = action
    }
    
    public var body: some View {
        FOMOListRow(showDivider: showDivider) {
            Button(action: { action?() }) {
                HStack(spacing: FOMOTheme.Spacing.medium) {
                    if let leadingAccessory = leadingAccessory {
                        leadingAccessory
                    }
                    
                    VStack(alignment: .leading, spacing: FOMOTheme.Spacing.xxxSmall) {
                        Text(title)
                            .font(FOMOTheme.Typography.bodyLarge)
                            .foregroundColor(FOMOTheme.Colors.text)
                            .lineLimit(1)
                        
                        if let subtitle = subtitle {
                            Text(subtitle)
                                .font(FOMOTheme.Typography.caption1)
                                .foregroundColor(FOMOTheme.Colors.textSecondary)
                                .lineLimit(2)
                        }
                    }
                    
                    Spacer()
                    
                    if let trailingAccessory = trailingAccessory {
                        trailingAccessory
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

// Convenience extensions for accessories
public extension FOMOTitleRow {
    /// Create a FOMOTitleRow with an icon as the leading accessory
    static func withIcon(
        title: String,
        subtitle: String? = nil,
        icon: String,
        iconColor: Color = FOMOTheme.Colors.primary,
        trailingAccessory: AnyView? = nil,
        showDivider: Bool = true,
        action: (() -> Void)? = nil
    ) -> FOMOTitleRow {
        FOMOTitleRow(
            title: title,
            subtitle: subtitle,
            leadingAccessory: AnyView(
                Image(systemName: icon)
                    .font(.headline)
                    .foregroundColor(iconColor)
                    .frame(width: 28, height: 28)
            ),
            trailingAccessory: trailingAccessory,
            showDivider: showDivider,
            action: action
        )
    }
    
    /// Create a FOMOTitleRow with a disclosure indicator
    static func withDisclosure(
        title: String,
        subtitle: String? = nil,
        leadingAccessory: AnyView? = nil,
        showDivider: Bool = true,
        action: @escaping () -> Void
    ) -> FOMOTitleRow {
        FOMOTitleRow(
            title: title,
            subtitle: subtitle,
            leadingAccessory: leadingAccessory,
            trailingAccessory: AnyView(
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(FOMOTheme.Colors.textSecondary)
            ),
            showDivider: showDivider,
            action: action
        )
    }
}

#if DEBUG
struct FOMOListRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            // Basic list row
            FOMOListRow {
                Text("Basic List Row")
                    .font(FOMOTheme.Typography.bodyLarge)
            }
            
            // Title row
            FOMOTitleRow(
                title: "Profile Settings",
                subtitle: "Update your personal information"
            )
            
            // Title row with icon
            FOMOTitleRow.withIcon(
                title: "Notifications",
                subtitle: "Configure your notification preferences",
                icon: "bell.fill",
                action: {}
            )
            
            // Title row with disclosure
            FOMOTitleRow.withDisclosure(
                title: "Privacy Settings",
                action: {}
            )
        }
        .background(FOMOTheme.Colors.background)
        .previewLayout(.sizeThatFits)
    }
} 