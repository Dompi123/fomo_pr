import Foundation
import SwiftUI

/// A utility to help migrate files to use FOMOTheme instead of direct styling.
/// This is a development-only tool to assist with refactoring.
public struct ThemeMigrationHelper {
    // Translation dictionaries for common patterns
    public struct Translations {
        static let fontMap: [String: String] = [
            ".font(.largeTitle)": ".font(FOMOTheme.Typography.display)",
            ".font(.title)": ".font(FOMOTheme.Typography.headlineLarge)",
            ".font(.title2)": ".font(FOMOTheme.Typography.headlineMedium)",
            ".font(.title3)": ".font(FOMOTheme.Typography.headlineSmall)",
            ".font(.headline)": ".font(FOMOTheme.Typography.headline)",
            ".font(.subheadline)": ".font(FOMOTheme.Typography.subheadline)",
            ".font(.body)": ".font(FOMOTheme.Typography.bodyRegular)",
            ".font(.callout)": ".font(FOMOTheme.Typography.callout)",
            ".font(.footnote)": ".font(FOMOTheme.Typography.footnote)",
            ".font(.caption)": ".font(FOMOTheme.Typography.caption1)",
            ".font(.caption2)": ".font(FOMOTheme.Typography.caption2)",
            
            // System font size variants
            ".font(.system(size: 34": ".font(FOMOTheme.Typography.display",
            ".font(.system(size: 28": ".font(FOMOTheme.Typography.headlineLarge",
            ".font(.system(size: 22": ".font(FOMOTheme.Typography.headlineMedium",
            ".font(.system(size: 20": ".font(FOMOTheme.Typography.headlineSmall",
            ".font(.system(size: 18": ".font(FOMOTheme.Typography.bodyLarge",
            ".font(.system(size: 16": ".font(FOMOTheme.Typography.bodyRegular",
            ".font(.system(size: 14": ".font(FOMOTheme.Typography.bodySmall",
            ".font(.system(size: 12": ".font(FOMOTheme.Typography.caption1",
            ".font(.system(size: 10": ".font(FOMOTheme.Typography.caption2",
        ]
        
        static let colorMap: [String: String] = [
            ".foregroundColor(.primary)": ".foregroundColor(FOMOTheme.Colors.text)",
            ".foregroundColor(.white)": ".foregroundColor(FOMOTheme.Colors.text)",
            ".foregroundColor(.black)": ".foregroundColor(FOMOTheme.Colors.text)",
            ".foregroundColor(.secondary)": ".foregroundColor(FOMOTheme.Colors.textSecondary)",
            ".foregroundColor(.gray)": ".foregroundColor(FOMOTheme.Colors.textSecondary)",
            ".foregroundColor(.red)": ".foregroundColor(FOMOTheme.Colors.error)",
            ".foregroundColor(.green)": ".foregroundColor(FOMOTheme.Colors.success)",
            ".foregroundColor(.yellow)": ".foregroundColor(FOMOTheme.Colors.warning)",
            ".foregroundColor(.purple)": ".foregroundColor(FOMOTheme.Colors.accent)",
            
            // Background colors
            ".background(Color.white)": ".background(FOMOTheme.Colors.surface)",
            ".background(Color.black)": ".background(FOMOTheme.Colors.background)",
            ".background(Color.gray)": ".background(FOMOTheme.Colors.surface)",
            ".background(Color.red)": ".background(FOMOTheme.Colors.error)",
            ".background(Color.green)": ".background(FOMOTheme.Colors.success)",
            ".background(Color.yellow)": ".background(FOMOTheme.Colors.warning)",
            ".background(Color.purple)": ".background(FOMOTheme.Colors.primary)",
        ]
        
        static let paddingMap: [String: String] = [
            ".padding(4)": ".padding(FOMOTheme.Spacing.xxSmall)",
            ".padding(8)": ".padding(FOMOTheme.Spacing.small)",
            ".padding(16)": ".padding(FOMOTheme.Spacing.medium)",
            ".padding(24)": ".padding(FOMOTheme.Spacing.large)",
            ".padding(32)": ".padding(FOMOTheme.Spacing.xLarge)",
            ".padding(.horizontal, 4)": ".padding(.horizontal, FOMOTheme.Spacing.xxSmall)",
            ".padding(.horizontal, 8)": ".padding(.horizontal, FOMOTheme.Spacing.small)",
            ".padding(.horizontal, 16)": ".padding(.horizontal, FOMOTheme.Spacing.medium)",
            ".padding(.horizontal, 24)": ".padding(.horizontal, FOMOTheme.Spacing.large)",
            ".padding(.vertical, 4)": ".padding(.vertical, FOMOTheme.Spacing.xxSmall)",
            ".padding(.vertical, 8)": ".padding(.vertical, FOMOTheme.Spacing.small)",
            ".padding(.vertical, 16)": ".padding(.vertical, FOMOTheme.Spacing.medium)",
            ".padding(.vertical, 24)": ".padding(.vertical, FOMOTheme.Spacing.large)",
        ]
        
        static let cornerRadiusMap: [String: String] = [
            ".cornerRadius(4)": ".cornerRadius(FOMOTheme.Radius.small)",
            ".cornerRadius(8)": ".cornerRadius(FOMOTheme.Radius.medium)",
            ".cornerRadius(16)": ".cornerRadius(FOMOTheme.Radius.large)",
        ]
    }
    
    // MARK: - Processing Methods
    
    /// Process a single Swift file and replace direct styling with FOMOTheme equivalents
    /// - Parameters:
    ///   - fileContents: The Swift file contents as a string
    ///   - applyModifiers: Whether to also apply composite modifiers where appropriate
    /// - Returns: The processed file contents with styling replaced
    public static func processSwiftFile(fileContents: String, applyModifiers: Bool = true) -> String {
        var processed = fileContents
        
        // Apply translations for direct styling
        for (directStyle, themeStyle) in Translations.fontMap {
            processed = processed.replacingOccurrences(of: directStyle, with: themeStyle)
        }
        
        for (directStyle, themeStyle) in Translations.colorMap {
            processed = processed.replacingOccurrences(of: directStyle, with: themeStyle)
        }
        
        for (directStyle, themeStyle) in Translations.paddingMap {
            processed = processed.replacingOccurrences(of: directStyle, with: themeStyle)
        }
        
        for (directStyle, themeStyle) in Translations.cornerRadiusMap {
            processed = processed.replacingOccurrences(of: directStyle, with: themeStyle)
        }
        
        // Apply composite modifiers if requested
        if applyModifiers {
            // Find patterns that could be replaced with composite modifiers
            
            // Pattern: .font(FOMOTheme.Typography.headlineMedium).foregroundColor(FOMOTheme.Colors.text)
            // Replace with: .fomoHeadline()
            processed = processed.replacingOccurrences(
                of: ".font(FOMOTheme.Typography.headlineMedium).foregroundColor(FOMOTheme.Colors.text)",
                with: ".fomoHeadline()"
            )
            
            // Pattern: .font(FOMOTheme.Typography.headlineLarge).foregroundColor(FOMOTheme.Colors.text)
            // Replace with: .fomoTitle()
            processed = processed.replacingOccurrences(
                of: ".font(FOMOTheme.Typography.headlineLarge).foregroundColor(FOMOTheme.Colors.text)",
                with: ".fomoTitle()"
            )
            
            // Pattern: .font(FOMOTheme.Typography.bodyRegular).foregroundColor(FOMOTheme.Colors.text)
            // Replace with: .fomoBodyText()
            processed = processed.replacingOccurrences(
                of: ".font(FOMOTheme.Typography.bodyRegular).foregroundColor(FOMOTheme.Colors.text)",
                with: ".fomoBodyText()"
            )
        }
        
        return processed
    }
}

// MARK: - Command Line Tool
#if DEBUG
// Sample usage in debug mode
// To use this script, call this from a development target
public struct ThemeMigrationDemo {
    public static func run() {
        let sampleCode = """
        VStack {
            Text("Hello World")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Description")
                .font(.body)
                .foregroundColor(.secondary)
                .padding(16)
            
            Button("Action") {
                print("Tapped")
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.purple)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding(24)
        .background(Color.white)
        .cornerRadius(16)
        """
        
        let processed = ThemeMigrationHelper.processSwiftFile(fileContents: sampleCode)
        print("Original:\n\(sampleCode)\n")
        print("Processed:\n\(processed)")
    }
}
#endif 