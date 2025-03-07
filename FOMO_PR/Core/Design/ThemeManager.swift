import SwiftUI
import Combine

/// Theme identifiers supported by the app
public enum ThemeType: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    case custom = "Custom"
    
    public var id: String { self.rawValue }
}

/// Protocol that defines what a theme should provide
public protocol Theme {
    var colors: ThemeColors { get }
    var id: ThemeType { get }
    var displayName: String { get }
}

/// Colors required for a theme
public struct ThemeColors {
    // Primary brand colors
    let primary: Color
    let secondary: Color
    let accent: Color
    
    // Semantic colors
    let success: Color
    let warning: Color
    let error: Color
    
    // Background colors
    let background: Color
    let surface: Color
    let surfaceElevated: Color
    
    // Text colors
    let textPrimary: Color
    let textSecondary: Color
    let textTertiary: Color
    
    public init(
        primary: Color,
        secondary: Color,
        accent: Color,
        success: Color,
        warning: Color,
        error: Color,
        background: Color,
        surface: Color,
        surfaceElevated: Color,
        textPrimary: Color,
        textSecondary: Color,
        textTertiary: Color
    ) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.success = success
        self.warning = warning
        self.error = error
        self.background = background
        self.surface = surface
        self.surfaceElevated = surfaceElevated
        self.textPrimary = textPrimary
        self.textSecondary = textSecondary
        self.textTertiary = textTertiary
    }
}

/// Default light theme implementation
public struct LightTheme: Theme {
    public var colors: ThemeColors = ThemeColors(
        primary: Color("PrimaryBrand"),
        secondary: Color("SecondaryBrand"),
        accent: Color("AccentBrand"),
        success: Color("Success"),
        warning: Color("Warning"),
        error: Color("Error"),
        background: Color("BackgroundLight"),
        surface: Color("SurfaceLight"),
        surfaceElevated: Color("SurfaceElevatedLight"),
        textPrimary: Color("TextPrimaryLight"),
        textSecondary: Color("TextSecondaryLight"),
        textTertiary: Color("TextTertiaryLight")
    )
    
    public var id: ThemeType = .light
    public var displayName: String = "Light"
}

/// Default dark theme implementation
public struct DarkTheme: Theme {
    public var colors: ThemeColors = ThemeColors(
        primary: Color("PrimaryBrand"),
        secondary: Color("SecondaryBrand"),
        accent: Color("AccentBrand"),
        success: Color("Success"),
        warning: Color("Warning"),
        error: Color("Error"),
        background: Color("BackgroundDark"),
        surface: Color("SurfaceDark"),
        surfaceElevated: Color("SurfaceElevatedDark"),
        textPrimary: Color("TextPrimaryDark"),
        textSecondary: Color("TextSecondaryDark"),
        textTertiary: Color("TextTertiaryDark")
    )
    
    public var id: ThemeType = .dark
    public var displayName: String = "Dark"
}

/// Theme manager that handles theme switching
public class ThemeManager: ObservableObject {
    /// Singleton instance
    public static let shared = ThemeManager()
    
    /// Currently active theme
    @Published public private(set) var activeTheme: Theme
    
    /// User's preferred theme type 
    @Published public var selectedThemeType: ThemeType {
        didSet {
            UserDefaults.standard.set(selectedThemeType.rawValue, forKey: "selectedTheme")
            updateActiveTheme()
        }
    }
    
    /// Available themes
    public private(set) var availableThemes: [Theme] = [
        LightTheme(),
        DarkTheme()
    ]
    
    /// Environment value for detecting system dark mode
    @AppStorage("isSystemInDarkMode") private var isSystemInDarkMode: Bool = false
    
    private init() {
        // Load saved theme preference
        let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme")
        self.selectedThemeType = ThemeType(rawValue: savedTheme ?? ThemeType.system.rawValue) ?? .system
        
        // Initialize with default theme
        self.activeTheme = LightTheme()
        updateActiveTheme()
        
        // Update active theme when system appearance changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(systemAppearanceChanged),
            name: Notification.Name("systemAppearanceChanged"),
            object: nil
        )
    }
    
    /// Update the active theme based on user preference
    private func updateActiveTheme() {
        switch selectedThemeType {
        case .light:
            activeTheme = availableThemes.first { $0.id == .light } ?? LightTheme()
        case .dark:
            activeTheme = availableThemes.first { $0.id == .dark } ?? DarkTheme()
        case .system:
            // Use system preference
            activeTheme = isSystemInDarkMode ?
                (availableThemes.first { $0.id == .dark } ?? DarkTheme()) :
                (availableThemes.first { $0.id == .light } ?? LightTheme())
        case .custom:
            // Custom theme would be handled here, default to light for now
            activeTheme = availableThemes.first { $0.id == .light } ?? LightTheme()
        }
        
        // Notify that theme has changed
        objectWillChange.send()
    }
    
    /// Called when system appearance changes
    @objc private func systemAppearanceChanged() {
        if selectedThemeType == .system {
            updateActiveTheme()
        }
    }
    
    /// Register a custom theme
    public func registerCustomTheme(_ theme: Theme) {
        if !availableThemes.contains(where: { $0.id == theme.id }) {
            availableThemes.append(theme)
        }
    }
}

/// Theme environment key to pass theme through the environment
public struct ThemeKey: EnvironmentKey {
    public static let defaultValue: Theme = LightTheme()
}

/// Environment extension for theme access
public extension EnvironmentValues {
    var theme: Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

/// View extension for theme support
public extension View {
    /// Apply the active theme to this view hierarchy
    func withTheme() -> some View {
        self.environmentObject(ThemeManager.shared)
            .environment(\.theme, ThemeManager.shared.activeTheme)
    }
}

/// Convenience extension to access theme colors
public extension Theme {
    var primary: Color { colors.primary }
    var secondary: Color { colors.secondary }
    var accent: Color { colors.accent }
    var success: Color { colors.success }
    var warning: Color { colors.warning }
    var error: Color { colors.error }
    var background: Color { colors.background }
    var surface: Color { colors.surface }
    var surfaceElevated: Color { colors.surfaceElevated }
    var textPrimary: Color { colors.textPrimary }
    var textSecondary: Color { colors.textSecondary }
    var textTertiary: Color { colors.textTertiary }
} 