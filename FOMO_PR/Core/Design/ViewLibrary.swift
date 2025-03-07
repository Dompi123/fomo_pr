import SwiftUI

/// A comprehensive library of all FOMO styled UI components
/// This file serves as both documentation and a reference for developers
struct ViewLibrary: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Text Styles").font(FOMOTheme.Typography.headline)) {
                    NavigationLink("Typography", destination: TypographyLibrary())
                }
                
                Section(header: Text("Common Components").font(FOMOTheme.Typography.headline)) {
                    NavigationLink("Buttons", destination: ButtonsLibrary())
                    NavigationLink("Cards", destination: CardsLibrary())
                    NavigationLink("Tags", destination: TagsLibrary())
                }
                
                Section(header: Text("Screen Components").font(FOMOTheme.Typography.headline)) {
                    NavigationLink("Venue Components", destination: VenueComponentsLibrary())
                    NavigationLink("Paywall Components", destination: PaywallComponentsLibrary())
                    NavigationLink("Drink Menu Components", destination: DrinkComponentsLibrary())
                }
                
                Section(header: Text("Before/After Examples").font(FOMOTheme.Typography.headline)) {
                    NavigationLink("Screen Examples", destination: BeforeAfterExamplesLibrary())
                }
            }
            .navigationTitle("FOMO UI Library")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

// MARK: - Typography Library
struct TypographyLibrary: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
                Group {
                    textStyleDemo("Title 1", modifier: { $0.fomoTitle1Style() })
                    textStyleDemo("Title 2", modifier: { $0.fomoTitle2Style() })
                    textStyleDemo("Headline", modifier: { $0.fomoHeadlineStyle() })
                    textStyleDemo("Body", modifier: { $0.fomoBodyStyle() })
                    textStyleDemo("Subheadline", modifier: { $0.fomoSubheadlineStyle() })
                    textStyleDemo("Caption", modifier: { $0.fomoCaptionStyle() })
                }
                
                Divider().padding(.vertical, FOMOTheme.Spacing.medium)
                
                Group {
                    textStyleDemo("Venue Title", modifier: { $0.venueTitleStyle() })
                    textStyleDemo("Venue Subtitle", modifier: { $0.venueSubtitleStyle() })
                    textStyleDemo("Venue Body", modifier: { $0.venueBodyStyle() })
                    textStyleDemo("Venue Caption", modifier: { $0.venueCaptionStyle() })
                    textStyleDemo("Venue Address", modifier: { $0.venueAddressStyle() })
                }
                
                Divider().padding(.vertical, FOMOTheme.Spacing.medium)
                
                Group {
                    textStyleDemo("Drink Title", modifier: { $0.drinkTitleStyle() })
                    textStyleDemo("Drink Description", modifier: { $0.drinkDescriptionStyle() })
                    textStyleDemo("Drink Price", modifier: { $0.drinkPriceStyle() })
                    textStyleDemo("Drink Quantity", modifier: { $0.drinkQuantityStyle() })
                }
            }
            .padding()
            .navigationTitle("Typography")
        }
    }
    
    func textStyleDemo<T: View>(_ title: String, modifier: (Text) -> T) -> some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.xSmall) {
            Text(title)
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            modifier(Text("The quick brown fox jumps over the lazy dog"))
            
            Text("Usage: .\\(title.lowercased().replacingOccurrences(of: " ", with: ""))Style()")
                .font(FOMOTheme.Typography.caption2)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
        }
        .padding()
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Radius.small)
    }
}

// MARK: - Buttons Library
struct ButtonsLibrary: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
                buttonDemo("Primary Button", modifier: { $0.fomoPrimaryButtonStyle() })
                buttonDemo("Secondary Button", modifier: { $0.fomoSecondaryButtonStyle() })
                buttonDemo("Venue Action Button", modifier: { $0.venueActionButtonStyle() })
                buttonDemo("Venue Action Button (Disabled)", modifier: { $0.venueActionButtonStyle(isEnabled: false) })
                buttonDemo("Paywall Button", modifier: { $0.paywallButtonStyle() })
                buttonDemo("Paywall Button (Disabled)", modifier: { $0.paywallButtonStyle(isEnabled: false) })
            }
            .padding()
            .navigationTitle("Buttons")
        }
    }
    
    func buttonDemo<T: View>(_ title: String, modifier: (Text) -> T) -> some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
            Text(title)
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            modifier(Text(title))
            
            let styleName = title
                .lowercased()
                .replacingOccurrences(of: " ", with: "")
                .replacingOccurrences(of: "(disabled)", with: "")
                .trimmingCharacters(in: .whitespaces)
            
            Text("Usage: .\\(styleName)Style()")
                .font(FOMOTheme.Typography.caption2)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
        }
        .padding()
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Radius.small)
    }
}

// MARK: - Cards Library
struct CardsLibrary: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
                cardDemo("Standard Card", modifier: { $0.fomoCardStyle() })
                venueCardDemo()
                drinkCardDemo()
                paywallCardDemo()
            }
            .padding()
            .navigationTitle("Cards")
        }
    }
    
    func cardDemo<T: View>(_ title: String, modifier: (VStack<TupleView<(Text, Text)>>) -> T) -> some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
            Text(title)
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            modifier(
                VStack(alignment: .leading) {
                    Text("Card Title")
                        .fomoHeadlineStyle()
                    
                    Text("This is card content with styling applied.")
                        .fomoBodyStyle()
                }
            )
            
            let styleName = title
                .lowercased()
                .replacingOccurrences(of: " ", with: "")
                .trimmingCharacters(in: .whitespaces)
            
            Text("Usage: .\\(styleName)Style()")
                .font(FOMOTheme.Typography.caption2)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
        }
        .padding()
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Radius.small)
    }
    
    func venueCardDemo() -> some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
            Text("Venue List Item")
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                Text("The Rooftop Bar")
                    .venueNameStyle()
                
                Text("A trendy rooftop bar with amazing city views and craft cocktails.")
                    .venueDescriptionStyle()
                
                HStack {
                    Image(systemName: "star.fill")
                        .venueRatingStyle()
                    Text("4.7")
                    
                    Spacer()
                    
                    Text("123 Main St, New York, NY")
                        .venueAddressStyle()
                }
            }
            .venueListItemStyle()
            .padding()
            .background(FOMOTheme.Colors.surface)
            .cornerRadius(FOMOTheme.Radius.medium)
            
            Text("Usage: .venueListItemStyle(), .venueNameStyle(), etc.")
                .font(FOMOTheme.Typography.caption2)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
        }
        .padding()
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Radius.small)
    }
    
    func drinkCardDemo() -> some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
            Text("Drink List Item")
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            HStack {
                Image(systemName: "wineglass")
                    .drinkIconStyle()
                
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.xxSmall) {
                    Text("Mojito")
                        .drinkTitleStyle()
                    
                    Text("Classic cocktail with rum, mint, lime, and sugar")
                        .drinkDescriptionStyle()
                    
                    Text("$12.99")
                        .drinkPriceStyle()
                }
                
                Spacer()
                
                Text("2×")
                    .drinkQuantityStyle()
            }
            .padding()
            .background(FOMOTheme.Colors.surface)
            .cornerRadius(FOMOTheme.Radius.medium)
            
            Text("Usage: .drinkTitleStyle(), .drinkDescriptionStyle(), etc.")
                .font(FOMOTheme.Typography.caption2)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
        }
        .padding()
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Radius.small)
    }
    
    func paywallCardDemo() -> some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
            Text("Subscription Option Card")
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            HStack {
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("Day Pass")
                        .fomoHeadlineStyle()
                    
                    Text("24-hour access to premium features")
                        .fomoSubheadlineStyle()
                    
                    Text("$9.99")
                        .fomoTextStyle(FOMOTheme.Typography.title3)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(FOMOTheme.Colors.primary)
            }
            .padding(FOMOTheme.Spacing.medium)
            .background(FOMOTheme.Colors.primary.opacity(0.1))
            .fomoCornerRadius()
            .overlay(
                RoundedRectangle(cornerRadius: FOMOTheme.Radius.medium)
                    .stroke(FOMOTheme.Colors.primary, lineWidth: 1)
            )
            
            Text("Custom subscription card from PaywallView")
                .font(FOMOTheme.Typography.caption2)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
        }
        .padding()
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Radius.small)
    }
}

// MARK: - Tags Library
struct TagsLibrary: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
                tagDemo("Standard Tag", modifier: { $0.fomoTagStyle() })
                tagDemo("Venue Tag", modifier: { $0.venueTagStyle() })
                
                HStack(spacing: FOMOTheme.Spacing.small) {
                    Text("Popular")
                        .venueTagStyle()
                    
                    Text("Trending")
                        .venueTagStyle()
                    
                    Text("Live Music")
                        .venueTagStyle()
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.small)
            }
            .padding()
            .navigationTitle("Tags")
        }
    }
    
    func tagDemo<T: View>(_ title: String, modifier: (Text) -> T) -> some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
            Text(title)
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            modifier(Text(title))
            
            let styleName = title
                .lowercased()
                .replacingOccurrences(of: " ", with: "")
                .trimmingCharacters(in: .whitespaces)
            
            Text("Usage: .\\(styleName)Style()")
                .font(FOMOTheme.Typography.caption2)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
        }
        .padding()
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Radius.small)
    }
}

// MARK: - Venue Components Library
struct VenueComponentsLibrary: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
                // Tab buttons
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("Venue Tab Buttons")
                        .font(FOMOTheme.Typography.caption1)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                    
                    HStack {
                        Text("Details")
                            .venueTabButtonStyle(isSelected: true)
                        
                        Text("Events")
                            .venueTabButtonStyle(isSelected: false)
                        
                        Text("Reviews")
                            .venueTabButtonStyle(isSelected: false)
                    }
                    .padding()
                    .background(FOMOTheme.Colors.surface)
                    
                    Text("Usage: .venueTabButtonStyle(isSelected: Bool)")
                        .font(FOMOTheme.Typography.caption2)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.small)
                
                // Info row
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("Venue Info Row")
                        .font(FOMOTheme.Typography.caption1)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                    
                    HStack {
                        Text("Hours")
                            .fomoCaptionStyle()
                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                        
                        Spacer()
                        
                        Text("5:00 PM - 2:00 AM")
                            .fomoBodyStyle()
                            .fontWeight(.medium)
                    }
                    .padding()
                    .background(FOMOTheme.Colors.surface)
                    
                    Text("Usage: InfoRow component")
                        .font(FOMOTheme.Typography.caption2)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.small)
                
                // Event row
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("Event Row")
                        .font(FOMOTheme.Typography.caption1)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                    
                    VStack(alignment: .leading, spacing: FOMOTheme.Spacing.xxSmall) {
                        Text("Event Title")
                            .fomoHeadlineStyle()
                        
                        HStack {
                            Text("Nov 15, 2023")
                                .fomoSubheadlineStyle()
                            
                            Text("•")
                                .foregroundColor(FOMOTheme.Colors.textSecondary)
                            
                            Text("8:00 PM")
                                .fomoSubheadlineStyle()
                        }
                    }
                    .padding(FOMOTheme.Spacing.medium)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(FOMOTheme.Colors.surface)
                    .fomoCornerRadius()
                    
                    Text("Usage: EventRow component")
                        .font(FOMOTheme.Typography.caption2)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.small)
            }
            .padding()
            .navigationTitle("Venue Components")
        }
    }
}

// MARK: - Paywall Components Library
struct PaywallComponentsLibrary: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
                // Paywall heading
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("Paywall Heading")
                        .font(FOMOTheme.Typography.caption1)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                    
                    Text("Choose Your Pass")
                        .paywallHeadingStyle()
                        .padding()
                        .background(FOMOTheme.Colors.surface)
                    
                    Text("Usage: .paywallHeadingStyle()")
                        .font(FOMOTheme.Typography.caption2)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.small)
                
                // Paywall button
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("Paywall Button")
                        .font(FOMOTheme.Typography.caption1)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                    
                    Text("Purchase Pass")
                        .fomoHeadlineStyle()
                        .paywallButtonStyle()
                    
                    Text("Usage: .paywallButtonStyle()")
                        .font(FOMOTheme.Typography.caption2)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.small)
                
                // Benefits item
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("Benefit Item")
                        .font(FOMOTheme.Typography.caption1)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                    
                    HStack(alignment: .top, spacing: FOMOTheme.Spacing.small) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(FOMOTheme.Colors.success)
                            .font(.system(size: 20))
                        
                        Text("Skip the line at entry")
                            .fomoBodyStyle()
                    }
                    .padding()
                    .background(FOMOTheme.Colors.surface)
                    
                    Text("From benefitsView in PaywallView")
                        .font(FOMOTheme.Typography.caption2)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.small)
            }
            .padding()
            .navigationTitle("Paywall Components")
        }
    }
}

// MARK: - Drink Components Library
struct DrinkComponentsLibrary: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
                // Drink image
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("Drink Image Style")
                        .font(FOMOTheme.Typography.caption1)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                    
                    Image(systemName: "wineglass")
                        .drinkIconStyle()
                    
                    Text("Usage: .drinkIconStyle()")
                        .font(FOMOTheme.Typography.caption2)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.small)
                
                // Empty state
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("Empty State Icon")
                        .font(FOMOTheme.Typography.caption1)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                    
                    Image(systemName: "wineglass")
                        .drinkEmptyIconStyle()
                    
                    Text("Usage: .drinkEmptyIconStyle()")
                        .font(FOMOTheme.Typography.caption2)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.small)
                
                // Error state
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("Error State Icon")
                        .font(FOMOTheme.Typography.caption1)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                    
                    Image(systemName: "exclamationmark.triangle")
                        .drinkErrorIconStyle()
                    
                    Text("Usage: .drinkErrorIconStyle()")
                        .font(FOMOTheme.Typography.caption2)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.small)
            }
            .padding()
            .navigationTitle("Drink Components")
        }
    }
}

// MARK: - Before/After Examples
struct BeforeAfterExamplesLibrary: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.large) {
                // PaywallView example
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("PaywallView")
                        .font(FOMOTheme.Typography.headline)
                    
                    VStack(alignment: .leading) {
                        Text("Before Refactoring")
                            .font(FOMOTheme.Typography.caption1)
                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                        
                        beforePaywallExample
                    }
                    
                    VStack(alignment: .leading) {
                        Text("After Refactoring")
                            .font(FOMOTheme.Typography.caption1)
                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                        
                        afterPaywallExample
                    }
                    
                    Text("Key improvements: Consistent spacing, semantic styling, reusable components")
                        .font(FOMOTheme.Typography.caption2)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.small)
                
                // ProfileView example
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("ProfileView")
                        .font(FOMOTheme.Typography.headline)
                    
                    VStack(alignment: .leading) {
                        Text("Before Refactoring")
                            .font(FOMOTheme.Typography.caption1)
                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                        
                        beforeProfileExample
                    }
                    
                    VStack(alignment: .leading) {
                        Text("After Refactoring")
                            .font(FOMOTheme.Typography.caption1)
                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                        
                        afterProfileExample
                    }
                    
                    Text("Key improvements: Consistent colors, semantic text styles")
                        .font(FOMOTheme.Typography.caption2)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.small)
                
                // VenueDetailView example
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text("VenueDetailView")
                        .font(FOMOTheme.Typography.headline)
                    
                    VStack(alignment: .leading) {
                        Text("Before Refactoring")
                            .font(FOMOTheme.Typography.caption1)
                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                        
                        beforeVenueDetailExample
                    }
                    
                    VStack(alignment: .leading) {
                        Text("After Refactoring")
                            .font(FOMOTheme.Typography.caption1)
                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                        
                        afterVenueDetailExample
                    }
                    
                    Text("Key improvements: Domain-specific styling, consistent components")
                        .font(FOMOTheme.Typography.caption2)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Radius.small)
            }
            .padding()
            .navigationTitle("Before/After Examples")
        }
    }
    
    // Example of code snippets showing before/after
    var beforePaywallExample: some View {
        VStack(alignment: .leading) {
            Text("Code Sample:")
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            Text("""
            Button(action: {}) {
                Text("Purchase Pass")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            """)
            .font(.system(size: 12, design: .monospaced))
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(FOMOTheme.Radius.small)
        }
    }
    
    var afterPaywallExample: some View {
        VStack(alignment: .leading) {
            Text("Code Sample:")
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            Text("""
            Button(action: {}) {
                Text("Purchase Pass")
                    .fomoHeadlineStyle()
                    .paywallButtonStyle()
            }
            """)
            .font(.system(size: 12, design: .monospaced))
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(FOMOTheme.Radius.small)
        }
    }
    
    var beforeProfileExample: some View {
        VStack(alignment: .leading) {
            Text("Code Sample:")
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            Text("""
            Text(name)
                .font(.headline)
            Text(email)
                .font(.subheadline)
                .foregroundColor(.gray)
            """)
            .font(.system(size: 12, design: .monospaced))
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(FOMOTheme.Radius.small)
        }
    }
    
    var afterProfileExample: some View {
        VStack(alignment: .leading) {
            Text("Code Sample:")
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            Text("""
            Text(name)
                .fomoHeadlineStyle()
            Text(email)
                .fomoSubheadlineStyle()
            """)
            .font(.system(size: 12, design: .monospaced))
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(FOMOTheme.Radius.small)
        }
    }
    
    var beforeVenueDetailExample: some View {
        VStack(alignment: .leading) {
            Text("Code Sample:")
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            Text("""
            EventRow(
                title: "Event Title",
                date: "Nov 15, 2023",
                time: "8:00 PM"
            )
            
            struct EventRow: View {
                var body: some View {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                        
                        HStack {
                            Text(date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("•")
                                .foregroundColor(.secondary)
                            
                            Text(time)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            """)
            .font(.system(size: 12, design: .monospaced))
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(FOMOTheme.Radius.small)
        }
    }
    
    var afterVenueDetailExample: some View {
        VStack(alignment: .leading) {
            Text("Code Sample:")
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            Text("""
            EventRow(
                title: "Event Title",
                date: "Nov 15, 2023",
                time: "8:00 PM"
            )
            
            struct EventRow: View {
                var body: some View {
                    VStack(alignment: .leading, spacing: FOMOTheme.Spacing.xxSmall) {
                        Text(title)
                            .fomoHeadlineStyle()
                        
                        HStack {
                            Text(date)
                                .fomoSubheadlineStyle()
                            
                            Text("•")
                                .foregroundColor(FOMOTheme.Colors.textSecondary)
                            
                            Text(time)
                                .fomoSubheadlineStyle()
                        }
                    }
                    .padding(FOMOTheme.Spacing.medium)
                    .background(FOMOTheme.Colors.surface)
                    .fomoCornerRadius()
                }
            }
            """)
            .font(.system(size: 12, design: .monospaced))
            .padding()
            .background(Color.black.opacity(0.1))
            .cornerRadius(FOMOTheme.Radius.small)
        }
    }
}

#if DEBUG
struct ViewLibrary_Previews: PreviewProvider {
    static var previews: some View {
        ViewLibrary()
            .preferredColorScheme(.dark)
    }
}
#endif 