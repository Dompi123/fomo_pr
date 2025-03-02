import SwiftUI
import Foundation

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
    let venue: Venue
    @StateObject private var viewModel: VenuePreviewViewModel
    
    init(venue: Venue) {
        self.venue = venue
        _viewModel = StateObject(wrappedValue: VenuePreviewViewModel(venueId: venue.id))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Venue Image
            if let imageURL = venue.imageURL {
                AsyncImage(url: imageURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    } else if phase.error != nil {
                        Color.gray
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.white)
                            )
                    } else {
                        Color.gray.opacity(0.3)
                            .frame(height: 200)
                            .overlay(ProgressView())
                    }
                }
                .cornerRadius(8)
            } else {
                Color.gray
                    .frame(height: 200)
                    .cornerRadius(8)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
            }
            
            // Venue Info
            VStack(alignment: .leading, spacing: 8) {
                Text(venue.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(venue.location)
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("Popular Venue")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .foregroundColor(.blue)
                    .cornerRadius(4)
                
                Text(venue.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
                    .padding(.top, 4)
            }
            
            // Action Buttons
            HStack(spacing: 16) {
                Button(action: {
                    // View menu action
                }) {
                    Text("View Menu")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                
                Button(action: {
                    // Buy pass action
                }) {
                    Text("Buy Pass")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Preview

struct VenuePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        VenuePreviewView(venue: Venue(
            id: "venue1",
            name: "The Grand Ballroom",
            description: "A luxurious venue for all your special events",
            location: "123 Main Street, New York, NY",
            imageURL: URL(string: "https://example.com/venue.jpg")
        ))
        .padding()
        .background(Color.gray.opacity(0.1))
        .previewLayout(.sizeThatFits)
    }
} 
