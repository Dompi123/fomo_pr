import SwiftUI

/**
 * ThemeShowcaseView: A comprehensive showcase of the FOMO design system
 * This view displays all UI components and styles in one place
 */
public struct ThemeShowcaseView: View {
    // MARK: - Properties
    
    @State private var selectedSection: Section = .overview
    
    // Form component states
    @State private var textFieldValue: String = ""
    @State private var emailFieldValue: String = "user@example.com"
    @State private var passwordFieldValue: String = "password123"
    @State private var toggleValue: Bool = true
    @State private var premiumToggleValue: Bool = false
    
    // MARK: - Body
    
    public var body: some View {
        NavigationView {
            List {
                // Section picker
                Picker("Section", selection: $selectedSection) {
                    ForEach(Section.allCases, id: \.self) { section in
                        Text(section.title)
                    }
                }
                .pickerStyle(.segmented)
                .listRowBackground(FOMOTheme.Colors.surface)
                .padding(.vertical, 8)
                
                // Section content
                Section {
                    sectionContent
                }
                .listRowBackground(FOMOTheme.Colors.surface)
            }
            .navigationTitle("Design System")
            .navigationBarTitleDisplayMode(.inline)
            .background(FOMOTheme.Colors.background)
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
            .tint(FOMOTheme.Colors.primary)
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Section Content
    
    @ViewBuilder
    private var sectionContent: some View {
        switch selectedSection {
        case .overview:
            overviewSection
        case .colors:
            colorsSection
        case .typography:
            typographySection
        case .forms:
            formsSection
        case .buttons:
            buttonsSection
        case .cards:
            cardsSection
        case .tags:
            tagsSection
        }
    }
    
    // MARK: - Overview Section
    
    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Introduction
            Group {
                FOMOText("FOMO Design System", style: .title1)
                FOMOText("A comprehensive design system for the FOMO app featuring Spotify-inspired styling with a focus on a premium nightlife experience.", style: .body)
            }
            
            // Color palette preview
            Group {
                FOMOText("Color Palette", style: .headline)
                
                HStack(spacing: 12) {
                    colorCircle(color: FOMOTheme.Colors.primary, name: "Primary")
                    colorCircle(color: FOMOTheme.Colors.secondary, name: "Secondary")
                    colorCircle(color: FOMOTheme.Colors.accent, name: "Accent")
                    colorCircle(color: FOMOTheme.Colors.success, name: "Success")
                }
            }
            
            // Typography preview
            Group {
                FOMOText("Typography", style: .headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    FOMOText("Title", style: .title1)
                    FOMOText("Headline", style: .headline)
                    FOMOText("Body Text", style: .body)
                }
            }
            
            // Form components preview
            Group {
                FOMOText("Form Components", style: .headline)
                
                FOMOTextField(
                    text: $textFieldValue,
                    placeholder: "Enter text",
                    icon: "text.cursor"
                )
                
                FOMOToggle(
                    isOn: $toggleValue,
                    label: "Toggle setting",
                    icon: "switch.2"
                )
            }
            
            // Component previews
            Group {
                FOMOText("Components", style: .headline)
                
                // Buttons preview
                HStack {
                    FOMOButton("Primary", size: .small, action: {})
                    FOMOButton("Premium", style: .premium, size: .small, action: {})
                }
                
                // Card preview
                FOMOCard(style: .primary) {
                    VStack(alignment: .leading, spacing: 8) {
                        FOMOText("Card Example", style: .headline)
                        FOMOText("Cards provide containment for related content", style: .body)
                    }
                    .padding(.vertical, 4)
                }
                
                // Tags preview
                HStack {
                    FOMOTag("Popular", style: .primary)
                    FOMOTag("Premium", icon: "star.fill", style: .premium)
                    FOMOTag("New", style: .success)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Forms Section
    
    private var formsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            FOMOText("Form Components", style: .title1)
            FOMOText("Our form components provide consistent input methods across the app with validation states and various styles.", style: .body)
            
            // Text Fields
            Group {
                FOMOText("Text Fields", style: .headline)
                
                VStack(alignment: .leading, spacing: 16) {
                    FOMOTextField(
                        text: $textFieldValue,
                        placeholder: "Enter your name",
                        title: "Full Name",
                        icon: "person",
                        helperText: "Please enter your legal name"
                    )
                    
                    FOMOTextField(
                        text: $emailFieldValue,
                        placeholder: "Enter your email",
                        title: "Email Address",
                        icon: "envelope",
                        errorMessage: emailFieldValue.contains("@") ? nil : "Please enter a valid email address",
                        inputType: .email
                    )
                    
                    FOMOTextField(
                        text: $passwordFieldValue,
                        placeholder: "Enter your password",
                        title: "Password",
                        icon: "lock",
                        helperText: "Must be at least 8 characters",
                        inputType: .password
                    )
                }
            }
            
            // Field Styles
            Group {
                FOMOText("Field Styles", style: .headline)
                
                HStack(spacing: 12) {
                    VStack {
                        FOMOTextField(
                            text: .constant("Default"),
                            placeholder: "Default",
                            style: .default
                        )
                        FOMOText(".default", style: .caption, color: FOMOTheme.Colors.textSecondary)
                    }
                    
                    VStack {
                        FOMOTextField(
                            text: .constant("Filled"),
                            placeholder: "Filled",
                            style: .filled
                        )
                        FOMOText(".filled", style: .caption, color: FOMOTheme.Colors.textSecondary)
                    }
                    
                    VStack {
                        FOMOTextField(
                            text: .constant("Minimal"),
                            placeholder: "Minimal",
                            style: .minimal
                        )
                        FOMOText(".minimal", style: .caption, color: FOMOTheme.Colors.textSecondary)
                    }
                }
            }
            
            // Toggle Switches
            Group {
                FOMOText("Toggle Switches", style: .headline)
                
                VStack(alignment: .leading, spacing: 16) {
                    FOMOToggle(
                        isOn: $toggleValue,
                        label: "Notifications",
                        secondaryText: "Enable push notifications",
                        icon: "bell.fill"
                    )
                    
                    FOMOToggle(
                        isOn: $premiumToggleValue,
                        label: "Premium Features",
                        secondaryText: "Enable exclusive premium features",
                        icon: "star.fill",
                        style: .premium
                    )
                }
            }
            
            // Toggle Styles
            Group {
                FOMOText("Toggle Styles", style: .headline)
                
                VStack(alignment: .leading, spacing: 12) {
                    FOMOToggle(
                        isOn: .constant(true),
                        label: "Primary Toggle",
                        style: .primary
                    )
                    
                    FOMOToggle(
                        isOn: .constant(true),
                        label: "Success Toggle",
                        style: .success
                    )
                    
                    FOMOToggle(
                        isOn: .constant(true),
                        label: "Premium Toggle",
                        style: .premium
                    )
                    
                    FOMOToggle(
                        isOn: .constant(true),
                        label: "Minimal Toggle",
                        style: .minimal
                    )
                    
                    FOMOToggle(
                        isOn: .constant(false),
                        label: "Disabled Toggle",
                        isEnabled: false
                    )
                }
            }
            
            // Input Types
            Group {
                FOMOText("Input Types", style: .headline)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        VStack {
                            FOMOTextField(
                                text: .constant("Text"),
                                placeholder: "Text",
                                inputType: .text
                            )
                            .frame(maxWidth: 120)
                            FOMOText(".text", style: .caption, color: FOMOTheme.Colors.textSecondary)
                        }
                        
                        VStack {
                            FOMOTextField(
                                text: .constant("user@mail.com"),
                                placeholder: "Email",
                                inputType: .email
                            )
                            .frame(maxWidth: 120)
                            FOMOText(".email", style: .caption, color: FOMOTheme.Colors.textSecondary)
                        }
                    }
                    
                    HStack(spacing: 12) {
                        VStack {
                            FOMOTextField(
                                text: .constant("123"),
                                placeholder: "Number",
                                inputType: .number
                            )
                            .frame(maxWidth: 120)
                            FOMOText(".number", style: .caption, color: FOMOTheme.Colors.textSecondary)
                        }
                        
                        VStack {
                            FOMOTextField(
                                text: .constant("******"),
                                placeholder: "Password",
                                inputType: .password
                            )
                            .frame(maxWidth: 120)
                            FOMOText(".password", style: .caption, color: FOMOTheme.Colors.textSecondary)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Colors Section
    
    private var colorsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            FOMOText("Color System", style: .title1)
            FOMOText("Our color system is based on a rich dark theme with vibrant purple and green accents, inspired by Spotify's design language.", style: .body)
            
            // Main colors
            Group {
                FOMOText("Main Colors", style: .headline)
                
                colorRow(color: FOMOTheme.Colors.primary, name: "Primary", hex: "#9C30FF")
                colorRow(color: FOMOTheme.Colors.primaryVariant, name: "Primary Variant", hex: "#7917D1")
                colorRow(color: FOMOTheme.Colors.secondary, name: "Secondary", hex: "#1DB954")
                colorRow(color: FOMOTheme.Colors.accent, name: "Accent", hex: "#BB86FC")
            }
            
            // Background colors
            Group {
                FOMOText("Background Colors", style: .headline)
                
                colorRow(color: FOMOTheme.Colors.background, name: "Background", hex: "#121212")
                colorRow(color: FOMOTheme.Colors.surface, name: "Surface", hex: "#282828")
                colorRow(color: FOMOTheme.Colors.surfaceVariant, name: "Surface Variant", hex: "#3E3E3E")
            }
            
            // Text colors
            Group {
                FOMOText("Text Colors", style: .headline)
                
                colorRow(color: FOMOTheme.Colors.text, name: "Text", hex: "White")
                colorRow(color: FOMOTheme.Colors.textSecondary, name: "Secondary Text", hex: "#B3B3B3")
            }
            
            // Status colors
            Group {
                FOMOText("Status Colors", style: .headline)
                
                colorRow(color: FOMOTheme.Colors.success, name: "Success", hex: "#1DB954")
                colorRow(color: FOMOTheme.Colors.warning, name: "Warning", hex: "#FFBD00")
                colorRow(color: FOMOTheme.Colors.error, name: "Error", hex: "#E61E32")
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Typography Section
    
    private var typographySection: some View {
        VStack(alignment: .leading, spacing: 20) {
            FOMOText("Typography System", style: .title1)
            FOMOText("Our typography system uses the system font with carefully selected weights and sizes for optimal readability and hierarchy.", style: .body)
            
            // Display and titles
            Group {
                FOMOText("Headings", style: .headline)
                
                VStack(alignment: .leading, spacing: 16) {
                    typographyRow(style: .display, text: "Display", description: "Extra large heading for hero sections")
                    typographyRow(style: .title1, text: "Title 1", description: "Main section headings")
                    typographyRow(style: .title2, text: "Title 2", description: "Subsection headings")
                }
            }
            
            // Body text styles
            Group {
                FOMOText("Body Text", style: .headline)
                
                VStack(alignment: .leading, spacing: 16) {
                    typographyRow(style: .headline, text: "Headline", description: "Emphasized text, card titles")
                    typographyRow(style: .subheadline, text: "Subheadline", description: "Secondary headlines")
                    typographyRow(style: .body, text: "Body", description: "Standard paragraph text")
                    typographyRow(style: .bodyLarge, text: "Body Large", description: "Emphasized body text")
                    typographyRow(style: .caption, text: "Caption", description: "Small supporting text")
                    typographyRow(style: .button, text: "Button", description: "Text used in buttons")
                }
            }
            
            // Font weights
            Group {
                FOMOText("Font Weights", style: .headline)
                
                HStack(spacing: 16) {
                    VStack {
                        Text("Regular")
                            .fontWeight(.regular)
                        Text("400")
                            .font(.caption)
                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                    }
                    
                    VStack {
                        Text("Medium")
                            .fontWeight(.medium)
                        Text("500")
                            .font(.caption)
                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                    }
                    
                    VStack {
                        Text("Semibold")
                            .fontWeight(.semibold)
                        Text("600")
                            .font(.caption)
                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                    }
                    
                    VStack {
                        Text("Bold")
                            .fontWeight(.bold)
                        Text("700")
                            .font(.caption)
                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                    }
                }
                .padding()
                .background(FOMOTheme.Colors.surface)
                .cornerRadius(FOMOTheme.Layout.cornerRadiusRegular)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Buttons Section
    
    private var buttonsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            FOMOText("Button System", style: .title1)
            FOMOText("Our button system provides consistent interactive elements across the app with multiple styles and sizes.", style: .body)
            
            // Style variants
            Group {
                FOMOText("Button Styles", style: .headline)
                
                VStack(alignment: .leading, spacing: 16) {
                    buttonRow(style: .primary, name: "Primary", description: "Main call to action")
                    buttonRow(style: .premium, name: "Premium", description: "Premium/featured actions")
                    buttonRow(style: .secondary, name: "Secondary", description: "Alternative actions")
                    buttonRow(style: .outline, name: "Outline", description: "Less prominent actions")
                    buttonRow(style: .ghost, name: "Ghost", description: "Minimal visual impact")
                }
            }
            
            // Size variants
            Group {
                FOMOText("Button Sizes", style: .headline)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        FOMOButton("Small", size: .small, action: {})
                        FOMOText("Small size for compact UI", style: .body)
                    }
                    
                    HStack {
                        FOMOButton("Medium", size: .medium, action: {})
                        FOMOText("Standard button size", style: .body)
                    }
                    
                    HStack {
                        FOMOButton("Large", size: .large, action: {})
                        FOMOText("Large size for emphasis", style: .body)
                    }
                }
            }
            
            // Button states
            Group {
                FOMOText("Button States", style: .headline)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        FOMOButton("Enabled", action: {})
                        FOMOText("Normal interactive state", style: .body)
                    }
                    
                    HStack {
                        FOMOButton("Disabled", isEnabled: false, action: {})
                        FOMOText("Non-interactive state", style: .body)
                    }
                }
            }
            
            // With icons
            Group {
                FOMOText("Buttons with Icons", style: .headline)
                
                HStack(spacing: 16) {
                    FOMOButton("Add to Cart", icon: "cart.badge.plus", action: {})
                    FOMOButton("Favorite", icon: "heart.fill", style: .outline, action: {})
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Cards Section
    
    private var cardsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            FOMOText("Card System", style: .title1)
            FOMOText("Our card system provides consistent containers for related content with multiple styles for different content types.", style: .body)
            
            // Card styles
            Group {
                FOMOText("Card Styles", style: .headline)
                
                cardRow(style: .primary, name: "Primary", description: "Standard content card")
                cardRow(style: .secondary, name: "Secondary", description: "Less prominent card")
                cardRow(style: .premium, name: "Premium", description: "Premium/featured content")
                cardRow(style: .minimal, name: "Minimal", description: "Minimal styling for simple content")
            }
            
            // Interactive cards
            Group {
                FOMOText("Interactive Cards", style: .headline)
                
                FOMOCard(style: .primary, isInteractive: true, action: {}) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            FOMOText("Interactive Card", style: .headline)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(FOMOTheme.Colors.textSecondary)
                        }
                        
                        FOMOText("This card responds to taps with hover effects and animations.", style: .body)
                    }
                    .padding(.vertical, 4)
                }
                
                FOMOText("Tap the card above to see the interactive effect.", style: .caption)
                    .foregroundColor(FOMOTheme.Colors.textSecondary)
            }
            
            // Real-world examples
            Group {
                FOMOText("Card Use Cases", style: .headline)
                
                // Venue card example
                FOMOCard(style: .primary) {
                    VStack(alignment: .leading, spacing: 12) {
                        // Image placeholder
                        Rectangle()
                            .fill(FOMOTheme.Colors.surfaceVariant)
                            .frame(height: 120)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(FOMOTheme.Colors.textSecondary)
                            )
                            .cornerRadius(FOMOTheme.Layout.cornerRadiusSmall)
                        
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                FOMOText("The Grand Ballroom", style: .headline)
                                FOMOText("123 Main Street", style: .caption)
                            }
                            
                            Spacer()
                            
                            FOMOTag("Premium", icon: "star.fill", style: .premium, size: .small)
                        }
                        
                        FOMOText("A luxurious venue for elegant events and nightlife experiences.", style: .body)
                        
                        HStack {
                            FOMOTag("Popular", style: .primary, size: .small)
                            FOMOTag("Live Music", style: .secondary, size: .small)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Tags Section
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            FOMOText("Tag System", style: .title1)
            FOMOText("Our tag system provides consistent labeling for categories, features, and status indicators.", style: .body)
            
            // Tag styles
            Group {
                FOMOText("Tag Styles", style: .headline)
                
                VStack(alignment: .leading, spacing: 16) {
                    tagRow(style: .primary, name: "Primary", description: "Standard tag for categories")
                    tagRow(style: .secondary, name: "Secondary", description: "Less prominent tag")
                    tagRow(style: .premium, name: "Premium", description: "Highlight premium features")
                    tagRow(style: .success, name: "Success", description: "Positive status indicator")
                    tagRow(style: .warning, name: "Warning", description: "Warning status indicator")
                    tagRow(style: .error, name: "Error", description: "Error or alert indicator")
                    tagRow(style: .outline, name: "Outline", description: "Minimal outline style")
                }
            }
            
            // Tag sizes
            Group {
                FOMOText("Tag Sizes", style: .headline)
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        FOMOTag("Small", size: .small)
                        FOMOText("Small size for compact UI", style: .body)
                    }
                    
                    HStack {
                        FOMOTag("Medium", size: .medium)
                        FOMOText("Standard tag size", style: .body)
                    }
                    
                    HStack {
                        FOMOTag("Large", size: .large)
                        FOMOText("Large size for emphasis", style: .body)
                    }
                }
            }
            
            // With icons
            Group {
                FOMOText("Tags with Icons", style: .headline)
                
                HStack(spacing: 12) {
                    FOMOTag("Premium", icon: "star.fill", style: .premium)
                    FOMOTag("New", icon: "sparkles", style: .primary)
                    FOMOTag("Alert", icon: "exclamationmark.triangle.fill", style: .warning)
                }
            }
            
            // Use cases
            Group {
                FOMOText("Tag Use Cases", style: .headline)
                
                VStack(spacing: 16) {
                    // Venue categories
                    HStack {
                        FOMOText("Venue Categories:", style: .subheadline)
                            .frame(width: 140, alignment: .leading)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FOMOTag("Nightclub", icon: "music.note", style: .primary)
                                FOMOTag("Rooftop", icon: "sunset", style: .primary)
                                FOMOTag("Live Music", icon: "guitars", style: .primary)
                                FOMOTag("Sports Bar", icon: "sportscourt", style: .primary)
                            }
                        }
                    }
                    
                    // Status indicators
                    HStack {
                        FOMOText("Status Indicators:", style: .subheadline)
                            .frame(width: 140, alignment: .leading)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FOMOTag("Open Now", icon: "checkmark.circle.fill", style: .success)
                                FOMOTag("Almost Full", icon: "person.2.fill", style: .warning)
                                FOMOTag("Closed", icon: "xmark.circle.fill", style: .error)
                            }
                        }
                    }
                    
                    // Feature labels
                    HStack {
                        FOMOText("Feature Labels:", style: .subheadline)
                            .frame(width: 140, alignment: .leading)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                FOMOTag("VIP Only", icon: "star.fill", style: .premium)
                                FOMOTag("New", icon: "sparkles", style: .primary)
                                FOMOTag("Trending", icon: "chart.line.uptrend.xyaxis", style: .primary)
                            }
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Helper Views
    
    private func colorCircle(color: Color, name: String) -> some View {
        VStack {
            Circle()
                .fill(color)
                .frame(width: 48, height: 48)
                .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
            
            Text(name)
                .font(.caption)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
        }
    }
    
    private func colorRow(color: Color, name: String, hex: String) -> some View {
        HStack {
            RoundedRectangle(cornerRadius: FOMOTheme.Layout.cornerRadiusSmall)
                .fill(color)
                .frame(width: 48, height: 48)
            
            VStack(alignment: .leading) {
                FOMOText(name, style: .subheadline)
                FOMOText(hex, style: .caption)
                    .foregroundColor(FOMOTheme.Colors.textSecondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func typographyRow(style: FOMOText.TextStyle, text: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            FOMOText(text, style: style)
            
            HStack {
                FOMOText(description, style: .caption)
                    .foregroundColor(FOMOTheme.Colors.textSecondary)
                Spacer()
                FOMOTag(style.name, size: .small)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func buttonRow(style: FOMOButton.ButtonStyle, name: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            FOMOButton(name, style: style, action: {})
            
            HStack {
                FOMOText(description, style: .body)
                Spacer()
                FOMOTag(".\(styleName(style))", size: .small)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func cardRow(style: FOMOCard<EmptyView>.CardStyle, name: String, description: String) -> some View {
        FOMOCard(style: style) {
            VStack(alignment: .leading, spacing: 8) {
                FOMOText(name + " Card", style: .headline)
                
                HStack {
                    FOMOText(description, style: .body)
                    Spacer()
                    FOMOTag(".\(styleName(style))", size: .small)
                }
            }
            .padding(.vertical, 4)
        }
    }
    
    private func tagRow(style: FOMOTag.TagStyle, name: String, description: String) -> some View {
        HStack {
            FOMOTag(name, style: style)
            
            VStack(alignment: .leading) {
                FOMOText(description, style: .body)
                FOMOText(".\(styleName(style))", style: .caption)
                    .foregroundColor(FOMOTheme.Colors.textSecondary)
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func styleName(_ style: FOMOButton.ButtonStyle) -> String {
        switch style {
        case .primary: return "primary"
        case .secondary: return "secondary"
        case .premium: return "premium"
        case .outline: return "outline"
        case .ghost: return "ghost"
        }
    }
    
    private func styleName(_ style: FOMOCard<EmptyView>.CardStyle) -> String {
        switch style {
        case .primary: return "primary"
        case .secondary: return "secondary"
        case .premium: return "premium"
        case .minimal: return "minimal"
        }
    }
    
    private func styleName(_ style: FOMOTag.TagStyle) -> String {
        switch style {
        case .primary: return "primary"
        case .secondary: return "secondary"
        case .premium: return "premium"
        case .success: return "success"
        case .warning: return "warning"
        case .error: return "error"
        case .outline: return "outline"
        }
    }
    
    // MARK: - Section Enum
    
    enum Section: String, CaseIterable {
        case overview
        case colors
        case typography
        case forms
        case buttons
        case cards
        case tags
        
        var title: String {
            switch self {
            case .overview: return "Overview"
            case .colors: return "Colors"
            case .typography: return "Typography"
            case .forms: return "Forms"
            case .buttons: return "Buttons"
            case .cards: return "Cards"
            case .tags: return "Tags"
            }
        }
    }
}

// MARK: - Typography Style Names

extension FOMOText.TextStyle {
    var name: String {
        switch self {
        case .display: return "display"
        case .title1: return "title1"
        case .title2: return "title2"
        case .headline: return "headline"
        case .subheadline: return "subheadline"
        case .body: return "body"
        case .bodyLarge: return "bodyLarge"
        case .caption: return "caption"
        case .button: return "button"
        }
    }
}

// MARK: - Preview

#Preview {
    ThemeShowcaseView()
        .preferredColorScheme(.dark)
} 