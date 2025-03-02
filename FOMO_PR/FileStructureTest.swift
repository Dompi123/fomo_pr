import Foundation
import SwiftUI

// This file helps diagnose file structure and module issues
// It doesn't rely on any external types

// Log file structure information
public func logFileStructure() {
    print("=== File Structure Test ===")
    
    // Get the main bundle
    let mainBundle = Bundle.main
    print("Main bundle: \(mainBundle.bundleIdentifier ?? "unknown")")
    print("Main bundle path: \(mainBundle.bundlePath)")
    
    // List all bundles
    print("All bundles:")
    for bundle in Bundle.allBundles {
        print("- \(bundle.bundleIdentifier ?? "unknown") at \(bundle.bundlePath)")
    }
    
    // Check if we can access the file system
    print("File system access:")
    let fileManager = FileManager.default
    let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
    print("Documents directory: \(documentsDirectory.path)")
    
    // Try to list files in the bundle
    print("Files in main bundle:")
    if let bundleURL = Bundle.main.bundleURL as NSURL? {
        do {
            let contents = try fileManager.contentsOfDirectory(at: bundleURL as URL, includingPropertiesForKeys: nil, options: [])
            for item in contents {
                print("- \(item.lastPathComponent)")
            }
        } catch {
            print("Error listing bundle contents: \(error.localizedDescription)")
        }
    }
    
    // Check for specific files
    let filesToCheck = [
        "KeychainManager.swift",
        "APIClientHelper.swift",
        "Network.swift"
    ]
    
    print("Checking for specific files:")
    for fileName in filesToCheck {
        if let fileURL = Bundle.main.url(forResource: fileName.components(separatedBy: ".").first, withExtension: "swift") {
            print("✅ Found \(fileName) at \(fileURL.path)")
        } else {
            print("❌ Could not find \(fileName) in main bundle")
        }
    }
    
    print("==============================")
}

// Struct to test if we can access the file system
public struct FileStructureTestView: View {
    @State private var testResult: String = "Press the button to test"
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("File Structure Test")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(testResult)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            Button("Test File Structure") {
                testFileStructure()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
    }
    
    private func testFileStructure() {
        var results: [String] = []
        
        results.append("File Structure Test Results:")
        
        // Check if we can access the file system
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        results.append("Documents directory: \(documentsDirectory.path)")
        
        // Check for specific files
        let filesToCheck = [
            "KeychainManager.swift",
            "APIClientHelper.swift",
            "Network.swift"
        ]
        
        for fileName in filesToCheck {
            if let _ = Bundle.main.url(forResource: fileName.components(separatedBy: ".").first, withExtension: "swift") {
                results.append("✅ Found \(fileName)")
            } else {
                results.append("❌ Could not find \(fileName)")
            }
        }
        
        // Check if we can access specific types
        let typeNames = ["APIClientHelper", "KeychainManager", "Network.APIClient"]
        for typeName in typeNames {
            if let _ = NSClassFromString(typeName) {
                results.append("✅ Type exists: \(typeName)")
            } else {
                results.append("❌ Type does not exist: \(typeName)")
            }
        }
        
        testResult = results.joined(separator: "\n")
    }
}

// Call the test function when the file is loaded
#if DEBUG
private let fileStructureTest: Void = {
    DispatchQueue.main.async {
        logFileStructure()
    }
    return ()
}()
#endif

#Preview {
    FileStructureTestView()
} 