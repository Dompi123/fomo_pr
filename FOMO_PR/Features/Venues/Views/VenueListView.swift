import SwiftUI
import Foundation

// Add import for core models
import Models
import Core

// MARK: - View Models

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

// Add extensions for missing properties in the core Venue model
extension Venue {
    var priceLevel: Int {
        // In a real app, this would come from the backend
        return 3
    }
    
    var category: String {
        return tags.first ?? "Venue"
    }
    
    var distance: Double {
        // In a real app, this would be calculated based on user's location
        return 0.5  // Default distance in miles
    }
}

class VenueListViewModel: ObservableObject {
    @Published var venues: [Venue] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var filters = VenueFilters()
    
    init() {
        loadVenues()
    }
    
    func loadVenues() {
        isLoading = true
        error = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: DispatchWorkItem {
            // In a real app, this would fetch venues from an API
            // For now, we'll use mock data
            self.venues = [
                Venue(
                    id: "venue1",
                    name: "The Grand Ballroom",
                    description: "A luxurious venue for all your special events",
                    address: "123 Main Street, New York, NY",
                    capacity: 500,
                    currentOccupancy: 250,
                    waitTime: 15,
                    imageURL: "https://example.com/venue1.jpg",
                    latitude: 40.7128,
                    longitude: -74.0060,
                    openingHours: "Mon-Sun: 10AM-10PM",
                    tags: ["Luxury", "Events", "Ballroom"],
                    rating: 4.8,
                    isOpen: true
                ),
                Venue(
                    id: "venue2",
                    name: "Skyline Lounge",
                    description: "Rooftop bar with amazing city views",
                    address: "456 Park Avenue, New York, NY",
                    capacity: 300,
                    currentOccupancy: 150,
                    waitTime: 30,
                    imageURL: "https://example.com/venue2.jpg",
                    latitude: 40.7580,
                    longitude: -73.9855,
                    openingHours: "Mon-Sun: 4PM-2AM",
                    tags: ["Rooftop", "Bar", "Views"],
                    rating: 4.5,
                    isOpen: true
                ),
                Venue(
                    id: "venue3",
                    name: "The Underground",
                    description: "Hip underground club with live music",
                    address: "789 Broadway, New York, NY",
                    capacity: 200,
                    currentOccupancy: 100,
                    waitTime: 45,
                    imageURL: "https://example.com/venue3.jpg",
                    latitude: 40.7484,
                    longitude: -73.9857,
                    openingHours: "Mon-Sun: 11AM-2AM",
                    tags: ["Hip", "Music", "Club"],
                    rating: 4.2,
                    isOpen: true
                )
            ]
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
                    Text("⭐ \(String(format: "%.1f", venue.rating))")
                    Text("•")
                    Text(String(repeating: "$", count: venue.priceLevel))
                    Text("•")
                    Text("Distance: \(venue.distance, specifier: "%.1f") miles")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Text(venue.isOpen ? "Open Now" : "Closed")
                    .font(.caption)
                    .foregroundColor(venue.isOpen ? .green : .red)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(Color.secondary)
        }
        .padding(.vertical, 8)
    }
}

struct VenueListView: View {
    @StateObject private var viewModel = VenueListViewModel()
    @State private var searchText = ""
    @State private var showingFilters = false
    @State private var selectedVenue: Venue?
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.isLoading {
                    ProgressView("Loading venues...")
                } else if let error = viewModel.error {
                    VStack {
                        Text("Error loading venues")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .font(.subheadline)
                            .foregroundColor(.red)
                        Button("Retry") {
                            viewModel.loadVenues()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                } else {
                    VStack {
                        searchBar
                        
                        if viewModel.filteredVenues(searchText: searchText).isEmpty {
                            VStack {
                                Text("No venues found")
                                    .font(.headline)
                                Text("Try adjusting your search or filters")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            venueList
                        }
                    }
                }
            }
            .navigationTitle("Venues")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingFilters.toggle()
                    }) {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .imageScale(.large)
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
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search venues", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var venueList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.filteredVenues(searchText: searchText)) { venue in
                        VenueCard(venue: venue)
                        .onTapGesture {
                            selectedVenue = venue
                    }
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct VenueCard: View {
    let venue: Venue
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageURLString = venue.imageURL, let imageURL = URL(string: imageURLString) {
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
                Text("⭐ \(String(format: "%.1f", venue.rating))")
                Text("•")
                Text(String(repeating: "$", count: venue.priceLevel))
                Text("•")
                Text("Distance: \(venue.distance, specifier: "%.1f") miles")
                    .font(.caption)
                    .foregroundColor(.secondary)
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

struct VenueFilters {
    var maxDistance: Double = 5.0
    var priceRange: ClosedRange<Double> = 0...500
    var categories: Set<String> = []
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

struct VenueListView_Previews: PreviewProvider {
    static var previews: some View {
            VenueListView()
    }
}

