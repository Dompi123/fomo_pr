import SwiftUI
import Foundation
import CoreLocation
import OSLog

// Commenting out Models import to use local implementations instead
// import Models
// Remove direct import of Core
// import Core

// Add import for our local implementations
import UIKit

// MARK: - View Models

// Add the missing VenueFilters struct
struct VenueFilters {
    var priceLevel: Int? = nil
    var category: String? = nil
    var isOpenNow: Bool = false
    var maxDistance: Double = 5.0
    var minRating: Double = 0.0
}

// Remove the duplicate Venue struct definition and use the one from FOMOTypes.swift
// The Venue struct is already defined in FOMOTypes.swift

// Comment out or remove duplicate definitions
/*
struct Venue: Identifiable {
    let id: String
    let name: String
    let description: String
    let address: String
    let imageURL: String
    let rating: Double
    let priceLevel: Int
    let category: String
    let isOpen: Bool
    let distance: Double?
}

extension Venue {
    static var preview: Venue {
        Venue(
            id: "venue1",
            name: "The Rooftop Bar",
            description: "A trendy rooftop bar with amazing city views and craft cocktails.",
            address: "123 Main St, New York, NY 10001",
            imageURL: "https://example.com/venue1.jpg",
            rating: 4.7,
            priceLevel: 3,
            category: "Bar",
            isOpen: true,
            distance: 0.5
        )
    }
}

enum FOMOTheme {
    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let background = Color.white
        static let text = Color.black
        static let accent = Color.orange
    }
    
    enum TextStyles {
        static let h1 = TextStyle(size: 24, weight: .bold)
        static let h2 = TextStyle(size: 20, weight: .bold)
        static let body = TextStyle(size: 16, weight: .regular)
        static let bodyBold = TextStyle(size: 16, weight: .bold)
        static let caption = TextStyle(size: 12, weight: .regular)
        static let button = TextStyle(size: 16, weight: .semibold)
    }
}

struct TextStyle {
    let size: CGFloat
    let weight: Font.Weight
}

extension Text {
    func fomoTextStyle(_ style: TextStyle) -> Text {
        self.font(.system(size: style.size, weight: style.weight))
    }
}
*/

// Uncomment the Venue struct
// struct Venue: Identifiable {
//     let id: String
//     let name: String
//     let description: String
//     let address: String
//     let imageURL: String
//     let rating: Double
//     let priceLevel: Int
//     let category: String
//     let isOpen: Bool
//     let distance: Double?
// }

// Remove all duplicate extensions for Venue

private let logger = Logger(subsystem: "com.fomo.pr", category: "VenueListView")

class VenueListViewModel: ObservableObject {
    @Published var venues: [Venue] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var filters = VenueFilters()
    
    init() {
        loadVenues()
    }
    
    func loadVenues() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: DispatchWorkItem {
            // In a real app, this would fetch venues from an API
            // For now, we'll use mock data
            self.venues = self.loadMockVenues()
            self.isLoading = false
        })
    }
    
    func filteredVenues(searchText: String) -> [Venue] {
        var filtered = venues
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { venue in
                venue.name.localizedCaseInsensitiveContains(searchText) ||
                venue.description.localizedCaseInsensitiveContains(searchText) ||
                venue.address.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply other filters if needed
        // ...
        
        return filtered
    }
    
    func fetchVenues() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // In a real app, this would be a network call
            // For now, use mock data
            await MainActor.run {
                self.venues = self.loadMockVenues()
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load venues: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // Helper function to create mock venues
    private func loadMockVenues() -> [Venue] {
        return [
            Venue(
                id: "venue1",
                name: "The Grand Ballroom",
                description: "A luxurious ballroom for elegant events",
                address: "123 Main Street, New York, NY",
                imageURL: URL(string: "https://example.com/venue1.jpg"),
                latitude: 40.7128,
                longitude: -74.0060,
                isPremium: true
            ),
            Venue(
                id: "venue2",
                name: "Skyline Lounge",
                description: "Rooftop lounge with panoramic city views",
                address: "456 Park Avenue, New York, NY",
                imageURL: URL(string: "https://example.com/venue2.jpg"),
                latitude: 40.7580,
                longitude: -73.9855,
                isPremium: true
            ),
            Venue(
                id: "venue3",
                name: "The Basement Club",
                description: "Underground club with live music",
                address: "789 Broadway, New York, NY",
                imageURL: URL(string: "https://example.com/venue3.jpg"),
                latitude: 40.7484,
                longitude: -73.9857,
                isPremium: false
            )
        ]
    }
}

// MARK: - Views

struct VenueListItemView: View {
    let venue: Venue
    
    var body: some View {
        HStack(spacing: 12) {
            // Venue image
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 80)
                .overlay(
                    Text(venue.name.prefix(1))
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                )
            
            // Venue details
            VStack(alignment: .leading, spacing: 4) {
                Text(venue.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(venue.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    Text(venue.isPremium ? "⭐⭐⭐⭐⭐" : "⭐⭐⭐⭐")
                    Text("•")
                    Text(venue.isPremium ? "$$$" : "$$")
                    Text("•")
                    Text(venue.isPremium ? "Premium" : "Standard")
                        .font(.caption)
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Text("Open Now")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct VenueListView: View {
    @EnvironmentObject private var navigationCoordinator: PreviewNavigationCoordinator
    @StateObject private var viewModel = VenueListViewModel()
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var selectedVenue: Venue?
    
    var body: some View {
        List {
            ForEach(filteredVenues) { venue in
                VenueRowView(venue: venue)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        logger.debug("Tapped venue: \(venue.name)")
                        if venue.isPremium {
                            navigationCoordinator.navigate(to: .drinkMenu(venue: venue))
                        } else {
                            navigationCoordinator.navigate(to: .paywall(venue: venue))
                        }
                    }
            }
        }
        .searchable(text: $searchText, prompt: "Search venues")
        .listStyle(PlainListStyle())
        .padding(.top, -35)
        .safeAreaInset(edge: .top) {
            Color.clear.frame(height: 0)
        }
        .refreshable {
            Task {
                await viewModel.fetchVenues()
            }
        }
        .onAppear {
            logger.debug("VenueListView appeared")
            Task {
                await viewModel.fetchVenues()
            }
        }
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingFilters.toggle()
                }) {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        .imageScale(.large)
                        .labelStyle(.titleAndIcon)
                }
            }
        }
        .sheet(isPresented: $showingFilters) {
            FilterView(viewModel: viewModel)
        }
        .sheet(item: $selectedVenue) { venue in
            NavigationView {
                VenueDetailView(venue: venue)
                    .navigationTitle(venue.name)
                    .navigationBarItems(trailing: Button("Done") {
                        selectedVenue = nil
                    })
            }
        }
    }
    
    private var filteredVenues: [Venue] {
        if searchText.isEmpty {
            return viewModel.venues
        } else {
            return viewModel.venues.filter { venue in
                venue.name.localizedCaseInsensitiveContains(searchText) ||
                venue.description.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct VenueRowView: View {
    let venue: Venue
    
    var body: some View {
        HStack(spacing: 16) {
            // Venue image
            if let imageURL = venue.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 80, height: 80)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure:
                        Image(systemName: "photo")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .frame(width: 80, height: 80)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 80, height: 80)
            } else {
                Image(systemName: "building.2")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                    .frame(width: 80, height: 80)
            }
            
            // Venue details
            VStack(alignment: .leading, spacing: 4) {
                Text(venue.name)
                    .font(.headline)
                
                Text(venue.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text(venue.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // Premium badge if applicable
                if venue.isPremium {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Premium")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                    .padding(.top, 2)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct VenueCard: View {
    let venue: Venue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageURL = venue.imageURL {
                AsyncImage(url: imageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 150)
                            .clipped()
                    } else if phase.error != nil {
                        Color.gray
                            .frame(height: 150)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                            )
                    } else {
                        Color.gray.opacity(0.3)
                            .frame(height: 150)
                            .overlay(ProgressView())
                    }
                }
                .cornerRadius(8)
            } else {
                Color.gray
                    .frame(height: 150)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
            }
            
            Text(venue.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(venue.address)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
            
            HStack {
                Text(venue.isPremium ? "⭐⭐⭐⭐⭐" : "⭐⭐⭐⭐")
                Text("•")
                Text(venue.isPremium ? "$$$" : "$$")
                Text("•")
                Text(venue.isPremium ? "Premium" : "Standard")
                    .font(.caption)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            
            Text(venue.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct VenuePassView: View {
    let venue: Venue
    
    var body: some View {
        Text("Pass purchase view for \(venue.name)")
            .navigationTitle("Buy Pass")
    }
}

struct FilterView: View {
    @ObservedObject var viewModel: VenueListViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var minPrice: Double = 0
    @State private var maxPrice: Double = 500
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Distance")) {
                    Slider(value: $viewModel.filters.maxDistance, in: 0.1...10, step: 0.1) {
                        Text("Maximum Distance")
                    } minimumValueLabel: {
                        Text("0.1 mi")
                    } maximumValueLabel: {
                        Text("10 mi")
                    }
                    Text("Within \(viewModel.filters.maxDistance, specifier: "%.1f") miles")
                }
                
                Section(header: Text("Price Range")) {
                    Slider(value: $minPrice, in: 0...maxPrice) {
                        Text("Minimum Price")
                    }
                    Slider(value: $maxPrice, in: minPrice...500) {
                        Text("Maximum Price")
                    }
                    Text("$\(Int(minPrice)) - $\(Int(maxPrice))")
                }
                
                // Add more filter options as needed
            }
            .navigationTitle("Filters")
            .navigationBarItems(
                leading: Button("Reset") {
                    viewModel.filters = VenueFilters()
                    minPrice = 0
                    maxPrice = 500
                },
                trailing: Button("Apply") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

// MARK: - Preview

#if DEBUG
struct VenueListView_Previews: PreviewProvider {
    static var previews: some View {
        VenueListView()
            .environmentObject(PreviewNavigationCoordinator.shared)
            .preferredColorScheme(.dark)
    }
}
#endif

