import Foundation
import SwiftUI

// MARK: - Security Namespace and TokenizationService
// This file provides a single source of truth for Security and TokenizationService types

// TokenizationService protocol is now imported from FOMOTypes.swift
// The implementation classes are defined in their respective files

// MARK: - Helper Function
// This function can be called to verify that the Security types are available
public func verifySecurityTypes() {
    print("Security namespace is available!")
    print("LiveTokenizationService is available: \(Security.LiveTokenizationService.self)")
    print("MockTokenizationService is available: \(Security.MockTokenizationService.self)")
}
