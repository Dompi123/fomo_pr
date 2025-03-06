import SwiftUI
import Foundation
// import Models // Commenting out Models import to use local implementations instead

// Add import for core models
// import Core // Commenting out Core import to use local implementations instead

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

// MARK: - VenuePreviewViewModel

// MARK: - Views

struct VenuePreviewView: View {
    @StateObject private var viewModel: VenuePreviewViewModel
    
    let venue: Venue
    
    init(venue: Venue) {
        self.venue = venue
        _viewModel = StateObject(wrappedValue: VenuePreviewViewModel(venue: venue))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Venue image
            if let imageURL = venue.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                ProgressView()
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                Text(venue.name.prefix(1))
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.white)
                            )
                    @unknown default:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Text(venue.name.prefix(1))
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.white)
                    )
            }
            
            // Venue name
            Text(venue.name)
                .font(.title)
                .fontWeight(.bold)
            
            // Venue category and rating
            HStack {
                Text(venue.isPremium ? "Premium Venue" : "Standard Venue")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(venue.isPremium ? "⭐⭐⭐⭐⭐" : "⭐⭐⭐⭐")
                    .font(.body)
                    .fontWeight(.bold)
            }
            
            // Price level and open status
            HStack {
                Text(venue.isPremium ? "$$$" : "$$")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("Open Now")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundColor(.green)
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
        .onAppear {
            viewModel.loadVenueDetails()
        }
    }
}

// MARK: - Preview

struct VenuePreviewView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a mock venue for preview
        let mockVenue = Venue(
            id: "venue_123",
            name: "The Rooftop Bar",
            description: "A trendy rooftop bar with amazing city views and craft cocktails.",
            address: "123 Main St, San Francisco, CA 94105",
            imageURL: URL(string: "https://example.com/venue.jpg"),
            latitude: 37.7749,
            longitude: -122.4194,
            isPremium: true
        )
        
        VenuePreviewView(venue: mockVenue)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
