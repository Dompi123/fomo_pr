import SwiftUI
import CoreLocation
import FOMO_PR  // Import for FOMOTheme (includes FOMOThemeExtensions)

// FOMOThemeExtensions is now part of FOMO_PR module - no separate import needed

struct VenueListView: View {
    @EnvironmentObject private var navigationCoordinator: PreviewNavigationCoordinator
    
    var body: some View {
        List {
            ForEach(0..<5) { index in
                VenueRowView(venue: sampleVenues[index % sampleVenues.count])
                    .onTapGesture {
                        navigationCoordinator.navigate(to: .paywall(venue: sampleVenues[index % sampleVenues.count]))
                    }
            }
        }
        .navigationTitle("Venues")
    }
    
    private var sampleVenues: [Venue] = [
        Venue(
            id: "venue1",
            name: "The Rooftop Bar",
            description: "A trendy rooftop bar with amazing city views and craft cocktails.",
            address: "123 Main St, New York, NY 10001",
            imageURL: nil,
            rating: 4.7
        ),
        Venue(
            id: "venue2",
            name: "Club Neon",
            description: "High-energy nightclub with top DJs and light shows.",
            address: "456 Broadway, New York, NY 10012",
            imageURL: nil,
            rating: 4.5
        ),
        Venue(
            id: "venue3",
            name: "Jazz Lounge",
            description: "Intimate jazz club with live performances nightly.",
            address: "789 5th Ave, New York, NY 10022",
            imageURL: nil,
            rating: 4.9
        )
    ]
}

struct VenueRowView: View {
    let venue: Venue
    
    var body: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
            Text(venue.name)
                .venueNameStyle()
            
            Text(venue.description)
                .venueDescriptionStyle()
            
            HStack {
                Image(systemName: "star.fill")
                    .venueRatingStyle()
                Text(String(format: "%.1f", venue.rating))
                
                Spacer()
                
                Text(venue.address)
                    .venueAddressStyle()
            }
        }
        .venueListItemStyle()
    }
}

#if DEBUG
struct VenueListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VenueListView()
                .environmentObject(PreviewNavigationCoordinator.shared)
        }
    }
}
#endif 