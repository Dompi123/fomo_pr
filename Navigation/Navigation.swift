//
// Navigation.swift
// FOMO_PR
//
// Central export point for navigation-related types.
//

@_exported import Foundation
@_exported import SwiftUI

// Re-export all navigation types for simpler imports
@_exported import struct Navigation.NavigationState
@_exported import enum Navigation.Sheet
@_exported import enum Navigation.Route
@_exported import protocol Navigation.FeatureAvailabilityChecking
@_exported import struct Navigation.DefaultFeatureAvailability
@_exported import class Navigation.NavigationCoordinator

// This file allows other files to simply import Navigation
// rather than importing each navigation type individually 