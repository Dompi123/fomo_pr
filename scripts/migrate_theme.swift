#!/usr/bin/env swift

import Foundation

// MARK: - Configuration
let rootDirectoryPath = "../FOMO_PR"  // Adjust to your project path if needed
let swiftFileExtension = "swift"
let outputExtension = "themed.swift"  // Files will be saved with this extension for review

// MARK: - Translation Tables
struct Translations {
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
    
    static let compositeModifiers: [String: String] = [
        ".font(FOMOTheme.Typography.headlineMedium).foregroundColor(FOMOTheme.Colors.text)": ".fomoHeadline()",
        ".font(FOMOTheme.Typography.headlineLarge).foregroundColor(FOMOTheme.Colors.text)": ".fomoTitle()",
        ".font(FOMOTheme.Typography.bodyRegular).foregroundColor(FOMOTheme.Colors.text)": ".fomoBodyText()",
        ".font(FOMOTheme.Typography.caption1).foregroundColor(FOMOTheme.Colors.textSecondary)": ".fomoCaption()",
        
        ".padding(FOMOTheme.Spacing.medium).background(FOMOTheme.Colors.surface).cornerRadius(FOMOTheme.Radius.medium)": ".fomoListItem()",
        
        ".padding(FOMOTheme.Spacing.medium).background(FOMOTheme.Colors.primary).foregroundColor(.white).cornerRadius(FOMOTheme.Radius.medium)": ".fomoPrimaryButton()",
    ]
}

// MARK: - Processing Functions

/// Process a single Swift file and replace direct styling with FOMOTheme equivalents
/// - Parameters:
///   - fileContents: The Swift file contents as a string
///   - applyCompositeModifiers: Whether to also apply composite modifiers where appropriate
/// - Returns: The processed file contents with styling replaced
func processSwiftFile(fileContents: String, applyCompositeModifiers: Bool = true) -> String {
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
    if applyCompositeModifiers {
        for (compositePattern, modifier) in Translations.compositeModifiers {
            processed = processed.replacingOccurrences(of: compositePattern, with: modifier)
        }
    }
    
    return processed
}

/// Process all Swift files in a directory recursively
/// - Parameter path: Path to the directory to process
func processDirectory(path: String) {
    let fileManager = FileManager.default
    
    // Get all file URLs in the directory
    guard let enumerator = fileManager.enumerator(atPath: path) else {
        print("Error: Could not create file enumerator for path: \(path)")
        return
    }
    
    var fileCount = 0
    var changedCount = 0
    
    while let file = enumerator.nextObject() as? String {
        if file.hasSuffix(".\(swiftFileExtension)") {
            fileCount += 1
            
            let filePath = (path as NSString).appendingPathComponent(file)
            
            // Skip files in the Core/Design directory since they're part of the design system
            if filePath.contains("Core/Design") && !filePath.contains("Components") {
                continue
            }
            
            do {
                let fileContents = try String(contentsOfFile: filePath, encoding: .utf8)
                let processedContents = processSwiftFile(fileContents: fileContents)
                
                if fileContents != processedContents {
                    changedCount += 1
                    
                    // Write the processed contents to a new file with the output extension
                    let outputPath = filePath.replacingOccurrences(of: ".\(swiftFileExtension)$", with: ".\(outputExtension)", options: .regularExpression)
                    try processedContents.write(toFile: outputPath, atomically: true, encoding: .utf8)
                    
                    print("Processed: \(file)")
                }
            } catch {
                print("Error processing file \(file): \(error.localizedDescription)")
            }
        }
    }
    
    print("Processed \(fileCount) files. Changed \(changedCount) files.")
}

// MARK: - Main Execution

// Print usage information
print("FOMO Theme Migration Tool")
print("========================")
print("This tool will process Swift files and convert direct styling to use FOMOTheme.")
print("Processed files will be saved with the .\(outputExtension) extension for review.")
print("")

// Start processing
print("Processing files in \(rootDirectoryPath)...")
processDirectory(path: rootDirectoryPath)
print("Done!") 