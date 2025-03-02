import SwiftUI
import Foundation

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
                    location: "123 Main Street, New York, NY",
                    imageURL: URL(string: "https://example.com/venue1.jpg")
                ),
                Venue(
                    id: "venue2",
                    name: "Skyline Lounge",
                    description: "Rooftop bar with amazing city views",
                    location: "456 Park Avenue, New York, NY",
                    imageURL: URL(string: "https://example.com/venue2.jpg")
                ),
                Venue(
                    id: "venue3",
                    name: "The Underground",
                    description: "Hip underground club with live music",
                    location: "789 Broadway, New York, NY",
                    imageURL: URL(string: "https://example.com/venue3.jpg")
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
                venue.location.localizedCaseInsensitiveContains(searchText)
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
                
                // Use a default category if not available
                Text("Venue")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("⭐ 4.5")
                    Text("•")
                    Text("$$$")
                    Text("•")
                    Text("0.5 mi")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                
                Text("Open Now")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
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
            
            Text(venue.location)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("Distance: 0.5 mi")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
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

