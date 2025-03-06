import SwiftUI

/// A view that demonstrates the impact of the design system by showing before/after comparisons.
/// This is used for both documentation and verification purposes.
public struct BeforeAfterGallery: View {
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                // Typography Section
                Section(header: Text("Typography").font(FOMOTheme.Typography.headlineSmall)) {
                    typographyComparison
                }
                
                // Color Section
                Section(header: Text("Colors").font(FOMOTheme.Typography.headlineSmall)) {
                    colorComparison
                }
                
                // Components Section
                Section(header: Text("Components").font(FOMOTheme.Typography.headlineSmall)) {
                    buttonComparison
                    cardComparison
                    listRowComparison
                }
                
                // Screens Section
                Section(header: Text("Screens").font(FOMOTheme.Typography.headlineSmall)) {
                    NavigationLink("Venue List", destination: venueListComparison)
                    NavigationLink("Paywall", destination: paywallComparison)
                    NavigationLink("Profile", destination: profileComparison)
                }
            }
            .navigationTitle("Before & After")
        }
    }
    
    // MARK: - Typography Comparisons
    
    private var typographyComparison: some View {
        VStack(spacing: FOMOTheme.Spacing.medium) {
            ComparisonView(
                title: "Headlines",
                beforeView: VStack(alignment: .leading, spacing: 8) {
                    Text("Large Headline").font(.largeTitle)
                    Text("Headline").font(.headline)
                    Text("Subheadline").font(.subheadline)
                },
                afterView: VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("Large Headline").font(FOMOTheme.Typography.headlineLarge)
                    Text("Headline").font(FOMOTheme.Typography.headlineMedium)
                    Text("Subheadline").font(FOMOTheme.Typography.headlineSmall)
                }
            )
            
            ComparisonView(
                title: "Body Text",
                beforeView: VStack(alignment: .leading, spacing: 8) {
                    Text("Body Text").font(.body)
                    Text("Caption").font(.caption)
                    Text("Footnote").font(.footnote)
                },
                afterView: VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("Body Text").font(FOMOTheme.Typography.bodyRegular)
                    Text("Caption").font(FOMOTheme.Typography.caption1)
                    Text("Small Text").font(FOMOTheme.Typography.bodySmall)
                }
            )
        }
        .padding()
    }
    
    // MARK: - Color Comparisons
    
    private var colorComparison: some View {
        VStack(spacing: FOMOTheme.Spacing.medium) {
            ComparisonView(
                title: "Primary Colors",
                beforeView: HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.purple)
                        .frame(width: 60, height: 40)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(width: 60, height: 40)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray)
                        .frame(width: 60, height: 40)
                },
                afterView: HStack(spacing: FOMOTheme.Spacing.small) {
                    RoundedRectangle(cornerRadius: FOMOTheme.Radius.small)
                        .fill(FOMOTheme.Colors.primary)
                        .frame(width: 60, height: 40)
                    RoundedRectangle(cornerRadius: FOMOTheme.Radius.small)
                        .fill(FOMOTheme.Colors.text)
                        .frame(width: 60, height: 40)
                    RoundedRectangle(cornerRadius: FOMOTheme.Radius.small)
                        .fill(FOMOTheme.Colors.textSecondary)
                        .frame(width: 60, height: 40)
                }
            )
            
            ComparisonView(
                title: "Status Colors",
                beforeView: HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.green)
                        .frame(width: 60, height: 40)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.yellow)
                        .frame(width: 60, height: 40)
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.red)
                        .frame(width: 60, height: 40)
                },
                afterView: HStack(spacing: FOMOTheme.Spacing.small) {
                    RoundedRectangle(cornerRadius: FOMOTheme.Radius.small)
                        .fill(FOMOTheme.Colors.success)
                        .frame(width: 60, height: 40)
                    RoundedRectangle(cornerRadius: FOMOTheme.Radius.small)
                        .fill(FOMOTheme.Colors.warning)
                        .frame(width: 60, height: 40)
                    RoundedRectangle(cornerRadius: FOMOTheme.Radius.small)
                        .fill(FOMOTheme.Colors.error)
                        .frame(width: 60, height: 40)
                }
            )
        }
        .padding()
    }
    
    // MARK: - Component Comparisons
    
    private var buttonComparison: some View {
        ComparisonView(
            title: "Buttons",
            beforeView: VStack(spacing: 8) {
                Button("Primary Button") {}
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
                Button("Secondary Button") {}
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.purple, lineWidth: 1)
                    )
            },
            afterView: VStack(spacing: FOMOTheme.Spacing.medium) {
                FOMOButton("Primary Button", style: .primary) {}
                FOMOButton("Secondary Button", style: .secondary) {}
            }
        )
        .padding()
    }
    
    private var cardComparison: some View {
        ComparisonView(
            title: "Cards",
            beforeView: VStack(alignment: .leading, spacing: 4) {
                Text("Card Title")
                    .font(.headline)
                Text("Card content goes here with a description.")
                    .font(.body)
            }
            .padding()
            .background(Color.gray.opacity(0.2))
            .cornerRadius(8),
            afterView: FOMOCard {
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("Card Title")
                        .font(FOMOTheme.Typography.headlineSmall)
                    Text("Card content goes here with a description.")
                        .font(FOMOTheme.Typography.bodyRegular)
                }
            }
        )
        .padding()
    }
    
    private var listRowComparison: some View {
        ComparisonView(
            title: "List Rows",
            beforeView: VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Row Title")
                        .font(.headline)
                    Text("Row subtitle with description")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                
                Divider()
            },
            afterView: FOMOTitleRow(
                title: "Row Title",
                subtitle: "Row subtitle with description"
            )
        )
        .padding()
    }
    
    // MARK: - Screen Comparisons
    
    private var venueListComparison: some View {
        ScrollView {
            VStack(spacing: FOMOTheme.Spacing.large) {
                Text("Venue List Screen")
                    .font(FOMOTheme.Typography.headlineLarge)
                    .padding(.top, FOMOTheme.Spacing.large)
                
                ComparisonImageView(
                    beforeImageName: "venueList_before",
                    afterImageName: "venueList_after",
                    description: "The venue list now uses consistent spacing, typography, and color tokens from the design system."
                )
                
                Text("Improvements")
                    .font(FOMOTheme.Typography.headlineSmall)
                
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    bulletPoint("Consistent spacing between list items")
                    bulletPoint("Typography follows design system hierarchy")
                    bulletPoint("Colors use semantic tokens")
                    bulletPoint("Cards use standard corner radius")
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.medium)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Venue List")
        .background(FOMOTheme.Colors.background)
    }
    
    private var paywallComparison: some View {
        ScrollView {
            VStack(spacing: FOMOTheme.Spacing.large) {
                Text("Paywall Screen")
                    .font(FOMOTheme.Typography.headlineLarge)
                    .padding(.top, FOMOTheme.Spacing.large)
                
                ComparisonImageView(
                    beforeImageName: "paywall_before",
                    afterImageName: "paywall_after",
                    description: "The paywall screen now uses consistent styling with the rest of the app."
                )
                
                Text("Improvements")
                    .font(FOMOTheme.Typography.headlineSmall)
                
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    bulletPoint("Buttons use shared FOMOButton component")
                    bulletPoint("Text uses design system typography")
                    bulletPoint("Custom paywall modifier for consistent styling")
                    bulletPoint("Visual hierarchy reinforced by typography")
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.medium)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Paywall")
        .background(FOMOTheme.Colors.background)
    }
    
    private var profileComparison: some View {
        ScrollView {
            VStack(spacing: FOMOTheme.Spacing.large) {
                Text("Profile Screen")
                    .font(FOMOTheme.Typography.headlineLarge)
                    .padding(.top, FOMOTheme.Spacing.large)
                
                ComparisonImageView(
                    beforeImageName: "profile_before",
                    afterImageName: "profile_after",
                    description: "The profile screen now uses FOMOTitleRow for consistent list items."
                )
                
                Text("Improvements")
                    .font(FOMOTheme.Typography.headlineSmall)
                
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    bulletPoint("List rows use FOMOTitleRow component")
                    bulletPoint("Section headers use consistent styling")
                    bulletPoint("Icons use semantic colors")
                    bulletPoint("Consistent spacing throughout")
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.medium)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Profile")
        .background(FOMOTheme.Colors.background)
    }
    
    // MARK: - Helper Views
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: FOMOTheme.Spacing.small) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(FOMOTheme.Colors.success)
                .font(.system(size: 16))
            
            Text(text)
                .font(FOMOTheme.Typography.bodyRegular)
                .foregroundColor(FOMOTheme.Colors.text)
        }
    }
}

/// A view that shows a before/after comparison of a component
struct ComparisonView<Before: View, After: View>: View {
    let title: String
    let beforeView: Before
    let afterView: After
    
    var body: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
            Text(title)
                .font(FOMOTheme.Typography.bodyLarge)
                .foregroundColor(FOMOTheme.Colors.text)
            
            HStack(alignment: .top, spacing: FOMOTheme.Spacing.large) {
                VStack {
                    Text("Before")
                        .font(FOMOTheme.Typography.caption1)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                        .padding(.bottom, 4)
                    
                    beforeView
                        .frame(maxWidth: .infinity)
                }
                
                VStack {
                    Text("After")
                        .font(FOMOTheme.Typography.caption1)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                        .padding(.bottom, 4)
                    
                    afterView
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

/// A view that shows before/after screenshots of a screen
struct ComparisonImageView: View {
    let beforeImageName: String
    let afterImageName: String
    let description: String
    
    // Images may not be available in the preview
    @State private var beforeImage: UIImage? = nil
    @State private var afterImage: UIImage? = nil
    
    var body: some View {
        VStack(spacing: FOMOTheme.Spacing.medium) {
            HStack(spacing: FOMOTheme.Spacing.large) {
                VStack {
                    Text("Before")
                        .font(FOMOTheme.Typography.caption1)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                    
                    if let image = beforeImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 400)
                            .cornerRadius(FOMOTheme.Radius.small)
                    } else {
                        placeholderImage
                    }
                }
                
                VStack {
                    Text("After")
                        .font(FOMOTheme.Typography.caption1)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                    
                    if let image = afterImage {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 400)
                            .cornerRadius(FOMOTheme.Radius.small)
                    } else {
                        placeholderImage
                    }
                }
            }
            
            Text(description)
                .font(FOMOTheme.Typography.bodySmall)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .onAppear {
            // Try to load actual images if available
            beforeImage = UIImage(named: beforeImageName)
            afterImage = UIImage(named: afterImageName)
        }
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(FOMOTheme.Colors.surface)
            .frame(width: 150, height: 300)
            .overlay(
                VStack {
                    Image(systemName: "photo")
                        .font(.system(size: 30))
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                    
                    Text("Screenshot\nNot Available")
                        .font(FOMOTheme.Typography.caption1)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            )
    }
}

#if DEBUG
struct BeforeAfterGallery_Previews: PreviewProvider {
    static var previews: some View {
        BeforeAfterGallery()
            .preferredColorScheme(.dark)
    }
}
#endif 