import Foundation
import OSLog

private let logger = Logger(subsystem: "com.fomo", category: "StringExtension")

private final class BundleToken {
    static let bundle: Bundle = {
        logger.debug("Initializing BundleToken bundle")
        let thisBundle = Bundle(for: BundleToken.self)
        logger.debug("Bundle path: \(thisBundle.bundlePath)")
        logger.debug("Bundle identifier: \(String(describing: thisBundle.bundleIdentifier))")
        #if SWIFT_PACKAGE
        logger.debug("Using SPM bundle")
        return Bundle.module
        #else
        logger.debug("Using framework bundle")
        return thisBundle
        #endif
    }()
}

public extension String {
    var localized: String {
        logger.debug("Localizing string: \(self)")
        logger.debug("Using bundle: \(BundleToken.bundle.bundlePath)")
        return NSLocalizedString(self, bundle: BundleToken.bundle, comment: "")
    }
} 