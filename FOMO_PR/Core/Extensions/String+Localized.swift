import Foundation
import OSLog

private let logger = Logger(subsystem: "com.fomo", category: "StringExtension")

private final class BundleToken {
    static let bundle: Bundle = {
        #if SWIFT_PACKAGE
        return Bundle.module
        #else
        // First try to get the bundle containing our current class
        let candidateBundle = Bundle(for: BundleToken.self)
        
        // Then look for a bundle named "Core" in the framework bundles
        if let resourcePath = candidateBundle.path(forResource: "Core", ofType: "bundle"),
           let resourceBundle = Bundle(path: resourcePath) {
            return resourceBundle
        }
        
        // Fallback to main bundle if we can't find the resource bundle
        return Bundle.main
        #endif
    }()
}

public extension String {
    var localized: String {
        let result = NSLocalizedString(self, bundle: BundleToken.bundle, comment: "")
        
        #if DEBUG
        if result == self {
            logger.warning("Missing localization for key: \(self)")
        }
        #endif
        
        return result
    }
} 