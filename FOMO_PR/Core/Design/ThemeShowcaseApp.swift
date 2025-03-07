import SwiftUI

/// App for showcasing the FOMO design system
public struct ThemeShowcaseApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    
    public init() {
        // Register fonts at app startup
        TypographySystem.registerFonts()
    }
    
    public var body: some Scene {
        WindowGroup {
            ThemeShowcaseTabView()
                .environmentObject(themeManager)
                .environment(\.theme, themeManager.activeTheme)
        }
    }
}

/// Main tab view for the theme showcase
struct ThemeShowcaseTabView: View {
    @State private var selectedTab = 0
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ThemeColorShowcase()
                .tabItem {
                    Label("Colors", systemImage: "paintpalette")
                }
                .tag(0)
            
            ThemeTypographyShowcase()
                .tabItem {
                    Label("Typography", systemImage: "textformat")
                }
                .tag(1)
            
            ThemeAnimationShowcase()
                .tabItem {
                    Label("Animations", systemImage: "wand.and.stars")
                }
                .tag(2)
            
            ThemeComponentShowcase()
                .tabItem {
                    Label("Components", systemImage: "square.on.square")
                }
                .tag(3)
            
            ThemeSettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .navigationTitle(navigationTitle)
        .withTheme()
    }
    
    private var navigationTitle: String {
        switch selectedTab {
        case 0: return "Colors"
        case 1: return "Typography"
        case 2: return "Animations"
        case 3: return "Components"
        case 4: return "Theme Settings"
        default: return "FOMO Design System"
        }
    }
}

/// View for showcasing colors in the theme
struct ThemeColorShowcase: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerSection
                
                brandColorsSection
                
                statusColorsSection
                
                backgroundColorsSection
                
                textColorsSection
                
                borderColorsSection
                
                gradientSection
            }
            .padding()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Color System")
                .font(TypographySystem.title1)
            
            Text("The FOMO design system color palette")
                .font(TypographySystem.body)
                .foregroundColor(theme.textSecondary)
        }
    }
    
    private var brandColorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Brand Colors")
                .font(TypographySystem.title3)
                .foregroundColor(theme.textPrimary)
            
            HStack(spacing: 16) {
                ColorSwatch(color: theme.primary, name: "Primary")
                ColorSwatch(color: theme.secondary, name: "Secondary")
                ColorSwatch(color: theme.accent, name: "Accent")
            }
        }
    }
    
    private var statusColorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Status Colors")
                .font(TypographySystem.title3)
                .foregroundColor(theme.textPrimary)
            
            HStack(spacing: 16) {
                ColorSwatch(color: theme.success, name: "Success")
                ColorSwatch(color: theme.warning, name: "Warning")
                ColorSwatch(color: theme.error, name: "Error")
                ColorSwatch(color: ColorSystem.Status.info, name: "Info")
            }
        }
    }
    
    private var backgroundColorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Background Colors")
                .font(TypographySystem.title3)
                .foregroundColor(theme.textPrimary)
            
            HStack(spacing: 16) {
                ColorSwatch(color: theme.background, name: "Background")
                ColorSwatch(color: theme.surface, name: "Surface")
                ColorSwatch(color: theme.surfaceElevated, name: "Surface Elevated")
            }
        }
    }
    
    private var textColorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Text Colors")
                .font(TypographySystem.title3)
                .foregroundColor(theme.textPrimary)
            
            HStack(spacing: 16) {
                ColorSwatch(color: theme.textPrimary, name: "Primary")
                ColorSwatch(color: theme.textSecondary, name: "Secondary")
                ColorSwatch(color: theme.textTertiary, name: "Tertiary")
            }
        }
    }
    
    private var borderColorsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Border Colors")
                .font(TypographySystem.title3)
                .foregroundColor(theme.textPrimary)
            
            HStack(spacing: 16) {
                ColorSwatch(color: ColorSystem.Border.standard, name: "Standard")
                ColorSwatch(color: ColorSystem.Border.subtle, name: "Subtle")
                ColorSwatch(color: ColorSystem.Border.focus, name: "Focus")
            }
        }
    }
    
    private var gradientSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Gradients")
                .font(TypographySystem.title3)
                .foregroundColor(theme.textPrimary)
            
            VStack(spacing: 16) {
                Rectangle()
                    .fill(ColorSystem.brandGradient)
                    .frame(height: 80)
                    .cornerRadius(FOMOTheme.Radius.medium)
                    .overlay(
                        Text("Brand Gradient")
                            .foregroundColor(.white)
                            .font(TypographySystem.headline)
                    )
                
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [theme.success, theme.primary]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 80)
                    .cornerRadius(FOMOTheme.Radius.medium)
                    .overlay(
                        Text("Success Gradient")
                            .foregroundColor(.white)
                            .font(TypographySystem.headline)
                    )
            }
        }
    }
}

/// View for showcasing typography in the theme
struct ThemeTypographyShowcase: View {
    @Environment(\.theme) private var theme
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerSection
                
                headingsSection
                
                bodyTextSection
                
                specialTextSection
                
                mixedStylesSection
            }
            .padding()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Typography System")
                .font(TypographySystem.title1)
            
            Text("The FOMO design system text styles")
                .font(TypographySystem.body)
                .foregroundColor(theme.textSecondary)
        }
    }
    
    private var headingsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Headings")
                .font(TypographySystem.title3)
                .foregroundColor(theme.textPrimary)
            
            Group {
                TypographyRow(name: "Large Title", style: TypographySystem.largeTitle)
                TypographyRow(name: "Title 1", style: TypographySystem.title1)
                TypographyRow(name: "Title 2", style: TypographySystem.title2)
                TypographyRow(name: "Title 3", style: TypographySystem.title3)
                TypographyRow(name: "Headline", style: TypographySystem.headline)
                TypographyRow(name: "Subheadline", style: TypographySystem.subheadline)
            }
        }
    }
    
    private var bodyTextSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Body Text")
                .font(TypographySystem.title3)
                .foregroundColor(theme.textPrimary)
            
            Group {
                TypographyRow(name: "Body", style: TypographySystem.body)
                TypographyRow(name: "Body Large", style: TypographySystem.bodyLarge)
                TypographyRow(name: "Body Small", style: TypographySystem.bodySmall)
                TypographyRow(name: "Caption", style: TypographySystem.caption)
            }
        }
    }
    
    private var specialTextSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Special Text")
                .font(TypographySystem.title3)
                .foregroundColor(theme.textPrimary)
            
            Group {
                TypographyRow(name: "Button", style: TypographySystem.button)
                TypographyRow(name: "Button Small", style: TypographySystem.buttonSmall)
                TypographyRow(name: "Label", style: TypographySystem.label)
            }
        }
    }
    
    private var mixedStylesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Text + Color Combinations")
                .font(TypographySystem.title3)
                .foregroundColor(theme.textPrimary)
            
            Text("Headline Primary")
                .headlinePrimary()
                .padding(.bottom, 4)
            
            Text("Body Secondary")
                .bodySecondary()
                .padding(.bottom, 4)
            
            Text("Caption Tertiary")
                .captionTertiary()
                .padding(.bottom, 4)
        }
    }
}

/// View for showcasing animations in the theme
struct ThemeAnimationShowcase: View {
    @Environment(\.theme) private var theme
    @State private var isAnimating = false
    @State private var showDetails = false
    @State private var bounceValue = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerSection
                
                transitionSection
                
                effectsSection
                
                realWorldSection
            }
            .padding()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Animation System")
                .font(TypographySystem.title1)
            
            Text("The FOMO design system animations")
                .font(TypographySystem.body)
                .foregroundColor(theme.textSecondary)
        }
    }
    
    private var transitionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Transitions")
                .font(TypographySystem.title3)
                .foregroundColor(theme.textPrimary)
            
            Button("Toggle Content") {
                withAnimation {
                    showDetails.toggle()
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(theme.primary)
            .cornerRadius(FOMOTheme.Radius.medium)
            
            if showDetails {
                Group {
                    Text("This content fades in and scales up slightly")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(theme.surface)
                        .cornerRadius(FOMOTheme.Radius.medium)
                        .animateAppear()
                    
                    Text("This content slides up from the bottom")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(theme.surface)
                        .cornerRadius(FOMOTheme.Radius.medium)
                        .animateSlideUp()
                }
            }
        }
    }
    
    private var effectsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Effects")
                .font(TypographySystem.title3)
                .foregroundColor(theme.textPrimary)
            
            Button("Trigger Bounce") {
                bounceValue += 1
            }
            .padding()
            .foregroundColor(.white)
            .background(theme.primary)
            .cornerRadius(FOMOTheme.Radius.medium)
            .animateBounce(on: bounceValue)
            .padding(.bottom, 8)
            
            Text("Auto-Pulsing Effect")
                .padding()
                .frame(maxWidth: .infinity)
                .background(theme.surface)
                .cornerRadius(FOMOTheme.Radius.medium)
                .animatePulse(autoRepeat: true)
                .padding(.bottom, 8)
            
            Text("Loading Content...")
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(FOMOTheme.Radius.medium)
                .animateShimmer()
        }
    }
    
    private var realWorldSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Real-World Examples")
                .font(TypographySystem.title3)
                .foregroundColor(theme.textPrimary)
            
            Button(action: {
                withAnimation(AnimationSystem.emphasizedSpring) {
                    isAnimating.toggle()
                }
            }) {
                Text("Buy Now")
                    .font(TypographySystem.button)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(theme.primary)
                    .cornerRadius(FOMOTheme.Radius.medium)
                    .scaleEffect(isAnimating ? 0.95 : 1.0)
            }
            .padding(.bottom, 20)
            
            // Simple notification
            if isAnimating {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(theme.success)
                    
                    Text("Added to cart successfully!")
                        .foregroundColor(theme.textPrimary)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isAnimating = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(theme.textSecondary)
                    }
                }
                .padding()
                .background(theme.surface)
                .cornerRadius(FOMOTheme.Radius.medium)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(1)
                .animateAppear()
            }
        }
    }
}

/// View for showcasing components
struct ThemeComponentShowcase: View {
    @Environment(\.theme) private var theme
    @State private var textInput = ""
    @State private var selectedTab = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerSection
                
                // This section would be populated with component examples 
                // once Agent 2 completes their task of creating components
                Text("Components will be available once they are implemented")
                    .font(TypographySystem.body)
                    .foregroundColor(theme.textSecondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(theme.surface)
                    .cornerRadius(FOMOTheme.Radius.medium)
            }
            .padding()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Component Library")
                .font(TypographySystem.title1)
            
            Text("Reusable UI components in the FOMO design system")
                .font(TypographySystem.body)
                .foregroundColor(theme.textSecondary)
        }
    }
}

/// View for theme settings
struct ThemeSettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                headerSection
                
                themeSelectionSection
                
                themePreviews
            }
            .padding()
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Theme Settings")
                .font(TypographySystem.title1)
            
            Text("Customize the appearance of the FOMO app")
                .font(TypographySystem.body)
                .foregroundColor(ThemeManager.shared.activeTheme.textSecondary)
        }
    }
    
    private var themeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Theme")
                .font(TypographySystem.title3)
                .foregroundColor(ThemeManager.shared.activeTheme.textPrimary)
            
            ForEach(ThemeType.allCases) { themeType in
                themeButton(for: themeType)
            }
        }
    }
    
    private func themeButton(for themeType: ThemeType) -> some View {
        Button(action: {
            themeManager.selectedThemeType = themeType
        }) {
            HStack {
                Text(themeType.rawValue)
                    .font(TypographySystem.body)
                
                Spacer()
                
                if themeManager.selectedThemeType == themeType {
                    Image(systemName: "checkmark")
                        .foregroundColor(ThemeManager.shared.activeTheme.primary)
                }
            }
            .padding()
            .background(ThemeManager.shared.activeTheme.surface)
            .cornerRadius(FOMOTheme.Radius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: FOMOTheme.Radius.medium)
                    .stroke(
                        themeManager.selectedThemeType == themeType ? 
                            ThemeManager.shared.activeTheme.primary : 
                            Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var themePreviews: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Theme Preview")
                .font(TypographySystem.title3)
                .foregroundColor(ThemeManager.shared.activeTheme.textPrimary)
            
            // Sample UI with current theme
            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Venue Details")
                            .font(TypographySystem.headline)
                            .foregroundColor(ThemeManager.shared.activeTheme.textPrimary)
                        
                        Text("Sample Club")
                            .font(TypographySystem.subheadline)
                            .foregroundColor(ThemeManager.shared.activeTheme.textSecondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "heart")
                        .foregroundColor(ThemeManager.shared.activeTheme.textSecondary)
                        .padding(8)
                        .background(ThemeManager.shared.activeTheme.surface)
                        .cornerRadius(FOMOTheme.Radius.medium)
                }
                
                // Image placeholder
                Rectangle()
                    .fill(ThemeManager.shared.activeTheme.surface)
                    .frame(height: 150)
                    .cornerRadius(FOMOTheme.Radius.medium)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(ThemeManager.shared.activeTheme.textSecondary)
                    )
                
                // Details
                VStack(alignment: .leading, spacing: 8) {
                    Text("About")
                        .font(TypographySystem.headline)
                        .foregroundColor(ThemeManager.shared.activeTheme.textPrimary)
                    
                    Text("This is a sample venue description that shows how text looks with the current theme.")
                        .font(TypographySystem.body)
                        .foregroundColor(ThemeManager.shared.activeTheme.textSecondary)
                }
                
                // Actions
                HStack(spacing: 16) {
                    Button(action: {}) {
                        Text("Get Tickets")
                            .font(TypographySystem.button)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(ThemeManager.shared.activeTheme.primary)
                            .cornerRadius(FOMOTheme.Radius.medium)
                    }
                    
                    Button(action: {}) {
                        Text("View Menu")
                            .font(TypographySystem.button)
                            .foregroundColor(ThemeManager.shared.activeTheme.primary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(ThemeManager.shared.activeTheme.surface)
                            .cornerRadius(FOMOTheme.Radius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: FOMOTheme.Radius.medium)
                                    .stroke(ThemeManager.shared.activeTheme.primary, lineWidth: 1)
                            )
                    }
                }
            }
            .padding()
            .background(ThemeManager.shared.activeTheme.background)
            .cornerRadius(FOMOTheme.Radius.medium)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

/// Helper view for typography showcase
struct TypographyRow: View {
    let name: String
    let style: Font
    @Environment(\.theme) private var theme
    
    var body: some View {
        HStack {
            Text(name)
                .font(TypographySystem.body)
                .foregroundColor(theme.textSecondary)
                .frame(width: 120, alignment: .leading)
            
            Text("The quick brown fox")
                .font(style)
                .foregroundColor(theme.textPrimary)
        }
        .padding(.vertical, 4)
    }
} 