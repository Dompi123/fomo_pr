import Foundation

// This file explicitly exports all public types from the Network module
// to ensure they are visible to other modules

// Re-export Foundation types
@_exported import struct Foundation.URL
@_exported import struct Foundation.Data

// No need for explicit typealias as APIClient is already public in APIClient.swift 