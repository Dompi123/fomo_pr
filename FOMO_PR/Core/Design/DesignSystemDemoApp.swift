import SwiftUI

/// A mini-app to demonstrate and test the FOMO design system.
/// This is a development tool and is not included in the production app.
struct DesignSystemDemoApp: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ThemeShowcaseView()
                .tabItem {
                    Label("Theme", systemImage: "paintpalette")
                }
                .tag(0)
            
            ComponentsDemoView()
                .tabItem {
                    Label("Components", systemImage: "rectangle.stack")
                }
                .tag(1)
            
            ViewLibrary()
                .tabItem {
                    Label("UI Library", systemImage: "square.grid.2x2")
                }
                .tag(2)
            
            ScreenShowcaseView()
                .tabItem {
                    Label("Screens", systemImage: "rectangle.3.group")
                }
                .tag(3)
            
            BeforeAfterExamplesView()
                .tabItem {
                    Label("Compare", systemImage: "arrow.left.arrow.right")
                }
                .tag(4)
            
            TypographyDemoView()
                .tabItem {
                    Label("Typography", systemImage: "textformat")
                }
                .tag(5)
            
            ColorsDemoView()
                .tabItem {
                    Label("Colors", systemImage: "eyedropper")
                }
                .tag(6)
        }
        .accentColor(FOMOTheme.Colors.primary)
    }
}

/// A view that showcases the entire design system
struct ThemeShowcaseView: View {
    var body: some View {
        NavigationView {
            FOMOThemePreview()
                .navigationTitle("FOMO Design System")
        }
    }
}

/// A view that demonstrates all the components
struct ComponentsDemoView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Buttons").font(FOMOTheme.Typography.headlineSmall)) {
                    buttonDemos
                }
                
                Section(header: Text("Cards").font(FOMOTheme.Typography.headlineSmall)) {
                    cardDemos
                }
                
                Section(header: Text("List Rows").font(FOMOTheme.Typography.headlineSmall)) {
                    listRowDemos
                }
            }
            .navigationTitle("Components")
        }
    }
    
    private var buttonDemos: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
            FOMOButton("Primary Button", style: .primary) {}
            
            FOMOButton("Secondary Button", style: .secondary) {}
            
            FOMOButton("Text Button", style: .text) {}
            
            FOMOButton("Disabled Button", style: .primary, isEnabled: false) {}
        }
        .padding(.vertical, FOMOTheme.Spacing.small)
    }
    
    private var cardDemos: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
            FOMOCard {
                Text("Standard Card")
                    .font(FOMOTheme.Typography.headlineSmall)
                    .foregroundColor(FOMOTheme.Colors.text)
                    .padding()
            }
            
            FOMOCard(padding: .small, backgroundColor: FOMOTheme.Colors.primary.opacity(0.1)) {
                Text("Custom Card")
                    .font(FOMOTheme.Typography.bodyRegular)
                    .foregroundColor(FOMOTheme.Colors.text)
            }
            
            VStack(alignment: .leading) {
                Text("Extension Card")
                    .font(FOMOTheme.Typography.headlineSmall)
                Text("Created using the .asCard() extension")
                    .font(FOMOTheme.Typography.caption1)
            }
            .padding()
            .asCard(padding: .none)
        }
        .padding(.vertical, FOMOTheme.Spacing.small)
    }
    
    private var listRowDemos: some View {
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
            
            FOMOListRow {
                Text("Custom Row Content")
                    .font(FOMOTheme.Typography.bodyRegular)
                    .foregroundColor(FOMOTheme.Colors.text)
            }
        }
        .padding(.vertical, FOMOTheme.Spacing.small)
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Radius.medium)
    }
}

/// A view that demonstrates all the typography styles
struct TypographyDemoView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
                    Group {
                        typographyDemo("Display", FOMOTheme.Typography.display)
                        typographyDemo("Headline Large", FOMOTheme.Typography.headlineLarge)
                        typographyDemo("Headline Medium", FOMOTheme.Typography.headlineMedium)
                        typographyDemo("Headline Small", FOMOTheme.Typography.headlineSmall)
                        typographyDemo("Body Large", FOMOTheme.Typography.bodyLarge)
                        typographyDemo("Body Regular", FOMOTheme.Typography.bodyRegular)
                        typographyDemo("Body Small", FOMOTheme.Typography.bodySmall)
                        typographyDemo("Caption 1", FOMOTheme.Typography.caption1)
                        typographyDemo("Caption 2", FOMOTheme.Typography.caption2)
                    }
                    
                    Divider()
                        .padding(.vertical, FOMOTheme.Spacing.medium)
                    
                    Group {
                        Text("Headline Modifier").fomoHeadline()
                        Text("Title Modifier").fomoTitle()
                        Text("Subtitle Modifier").fomoSubtitle()
                        Text("Body Text Modifier").fomoBodyText()
                        Text("Caption Modifier").fomoCaption()
                    }
                }
                .padding()
            }
            .navigationTitle("Typography")
        }
    }
    
    func typographyDemo(_ name: String, _ font: Font) -> some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.xSmall) {
            Text(name)
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            Text("The quick brown fox jumps over the lazy dog")
                .font(font)
                .foregroundColor(FOMOTheme.Colors.text)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Radius.small)
    }
}

/// A view that demonstrates all the colors
struct ColorsDemoView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: FOMOTheme.Spacing.medium) {
                    colorDemo("Primary", FOMOTheme.Colors.primary)
                    colorDemo("Secondary", FOMOTheme.Colors.secondary)
                    colorDemo("Background", FOMOTheme.Colors.background)
                    colorDemo("Surface", FOMOTheme.Colors.surface)
                    colorDemo("Text", FOMOTheme.Colors.text)
                    colorDemo("Text Secondary", FOMOTheme.Colors.textSecondary)
                    colorDemo("Accent", FOMOTheme.Colors.accent)
                    colorDemo("Success", FOMOTheme.Colors.success)
                    colorDemo("Warning", FOMOTheme.Colors.warning)
                    colorDemo("Error", FOMOTheme.Colors.error)
                }
                .padding()
            }
            .navigationTitle("Colors")
        }
    }
    
    func colorDemo(_ name: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
            Rectangle()
                .fill(color)
                .frame(height: 100)
                .cornerRadius(FOMOTheme.Radius.small)
            
            Text(name)
                .font(FOMOTheme.Typography.bodyRegular)
                .foregroundColor(FOMOTheme.Colors.text)
            
            Text("FOMOTheme.Colors.\(name.lowercased().replacingOccurrences(of: " ", with: ""))")
                .font(FOMOTheme.Typography.caption1)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
        }
    }
}

/// A view that showcases real app screens
struct ScreenShowcaseView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Primary User Journey")) {
                    NavigationLink("Venue List", destination: VenueListScreenExample())
                    NavigationLink("Venue Detail", destination: VenueDetailScreenExample())
                    NavigationLink("Drink Menu", destination: DrinkMenuScreenExample())
                }
                
                Section(header: Text("Secondary Screens")) {
                    NavigationLink("Paywall", destination: PaywallScreenExample())
                    NavigationLink("Profile", destination: ProfileScreenExample())
                    NavigationLink("Passes", destination: PassesScreenExample())
                }
                
                Section(header: Text("Before & After")) {
                    NavigationLink("Styling Comparison", destination: BeforeAfterExamplesLibrary())
                }
            }
            .navigationTitle("App Screens")
        }
    }
}

// Screen examples
struct VenueListScreenExample: View {
    var body: some View {
        Text("Venue List Screen Example would go here")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FOMOTheme.Colors.background)
    }
}

struct VenueDetailScreenExample: View {
    var body: some View {
        Text("Venue Detail Screen Example would go here")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FOMOTheme.Colors.background)
    }
}

struct DrinkMenuScreenExample: View {
    var body: some View {
        Text("Drink Menu Screen Example would go here")
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FOMOTheme.Colors.background)
    }
}

struct PaywallScreenExample: View {
    var body: some View {
        PaywallView(venue: PreviewData.venue)
    }
}

struct ProfileScreenExample: View {
    var body: some View {
        ProfileView()
    }
}

struct PassesScreenExample: View {
    var body: some View {
        PassesView()
    }
}

// MARK: - Screen Before & After Examples
struct BeforeAfterExamplesView: View {
    var body: some View {
        List {
            Section(header: Text("PaywallView").font(FOMOTheme.Typography.headlineSmall)) {
                NavigationLink("Before", destination: PaywallBeforeExample())
                NavigationLink("After", destination: PaywallScreenExample())
            }
            
            Section(header: Text("ProfileView").font(FOMOTheme.Typography.headlineSmall)) {
                NavigationLink("Before", destination: ProfileBeforeExample())
                NavigationLink("After", destination: ProfileScreenExample())
            }
            
            Section(header: Text("PassesView").font(FOMOTheme.Typography.headlineSmall)) {
                NavigationLink("Before", destination: PassesBeforeExample())
                NavigationLink("After", destination: PassesScreenExample())
            }
        }
        .navigationTitle("Before & After")
    }
}

struct PaywallBeforeExample: View {
    var body: some View {
        VStack {
            Text("Before Refactoring")
                .font(.headline)
                .padding()
            
            ScrollView {
                VStack(spacing: 20) {
                    Text("Venue Name")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Select a Pass")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    ForEach(0..<3) { _ in
                        VStack(alignment: .leading) {
                            Text("Pass Option")
                                .font(.headline)
                            Text("Pass description goes here")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("$29.99")
                                .font(.title3)
                                .fontWeight(.bold)
                                .padding(.top, 5)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                    }
                    
                    Text("Purchase")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .padding(.top, 20)
                }
                .padding(.vertical)
            }
        }
    }
}

struct ProfileBeforeExample: View {
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text("John Doe")
                            .font(.headline)
                        Text("john.doe@example.com")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section(header: Text("Account")) {
                NavigationLink(destination: EmptyView()) {
                    Label("Payment Methods", systemImage: "creditcard")
                }
                
                NavigationLink(destination: EmptyView()) {
                    Label("Purchase History", systemImage: "bag")
                }
            }
            
            Section {
                Button(action: {}) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Profile")
    }
}

struct PassesBeforeExample: View {
    var body: some View {
        VStack {
            Image(systemName: "ticket")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding()
            
            Text("My Passes")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 4)
            
            Text("You don't have any passes yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 16)
            
            Button(action: {}) {
                Text("Browse Venues")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
        .padding()
        .navigationTitle("My Passes")
    }
}

#if DEBUG
struct DesignSystemDemoApp_Previews: PreviewProvider {
    static var previews: some View {
        DesignSystemDemoApp()
            .preferredColorScheme(.dark)
    }
}
#endif 