import SwiftUI
import Foundation

// Add import for core models
import Models
import Core

// MARK: - Models

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

enum FOMOTheme {
    enum Colors {
        static let primary = Color.blue
        static let secondary = Color.gray
        static let background = Color.white
        static let text = Color.black
        static let accent = Color.orange
    }
}

class BaseViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    func simulateNetworkDelay() async {
        do {
            try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
        } catch {
            // Ignore cancellation errors
        }
    }
}

class VenuePreviewViewModel: BaseViewModel {
    @Published var venue: Venue
    
    init(venue: Venue) {
        self.venue = venue
        super.init()
    }
}

func getMockVenueDetails(id: String) -> Venue {
    Venue(
        id: id,
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
*/

// MARK: - Views

struct VenuePreviewView: View {
    @StateObject private var viewModel: VenuePreviewViewModel
    
    let venue: Venue
    
    init(venue: Venue) {
        self.venue = venue
        _viewModel = StateObject(wrappedValue: VenuePreviewViewModel(venueId: venue.id))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Venue image
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 200)
                .overlay(
                    Text(venue.name.prefix(1))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                )
            
            // Venue name
            Text(venue.name)
                .font(.title)
                .fontWeight(.bold)
            
            // Venue category and rating
            HStack {
                Text(venue.category)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("⭐ \(String(format: "%.1f", venue.rating))")
                    .font(.body)
                    .fontWeight(.bold)
            }
            
            // Price level and open status
            HStack {
                Text(String(repeating: "$", count: venue.priceLevel))
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(venue.isOpen ? "Open Now" : "Closed")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(venue.isOpen ? Color.green.opacity(0.2) : Color.red.opacity(0.2))
                    .foregroundColor(venue.isOpen ? .green : .red)
                    .cornerRadius(4)
            }
            
            // Address
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.secondary)
                
                Text(venue.address)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Description
            Text(venue.description)
                .font(.body)
                .foregroundColor(.primary)
                .padding(.top, 8)
            
            Spacer()
            
            // Action buttons
            HStack {
                Button(action: {
                    // View menu action
                }) {
                    Text("View Menu")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    // Buy pass action
                }) {
                    Text("Buy Pass")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
    }
}

// MARK: - Preview

struct VenuePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        VenuePreviewView(venue: Venue.preview)
            .previewLayout(.sizeThatFits)
            .padding()
    }
} 
