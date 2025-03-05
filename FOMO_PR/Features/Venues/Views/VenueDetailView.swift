import SwiftUI
import Foundation
import OSLog
// import Models // Commenting out Models import to use local implementations instead
// import Core // Commenting out Core import to use local implementations instead

struct VenueDetailView: View {
    let venue: Venue
    @State private var selectedTab = 0
    @State private var showingPassPurchase = false
    @State private var showingMenu = false
    @State private var isLoading = false
    @State private var error: Error?
    
    private let logger = Logger(subsystem: "com.fomo", category: "VenueDetail")
    
    var body: some View {
        ScrollView {
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
                } else {
                    Color.gray
                        .frame(height: 200)
                }
                
                // Venue Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(venue.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(venue.address)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text(venue.description)
                        .font(.body)
                        .padding(.top, 8)
                }
                .padding(.horizontal)
                
                // Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(["Popular", "Trending", "Live Music"], id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Action Buttons
                HStack(spacing: 16) {
                    Button(action: {
                        showingMenu = true
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
                        showingPassPurchase = true
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
                .padding(.horizontal)
                
                // Tabs
                VStack(spacing: 0) {
                    HStack {
                        TabButton(text: "Details", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        
                        TabButton(text: "Events", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        
                        TabButton(text: "Reviews", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                    }
                    .padding(.horizontal)
                    
                    // Tab Content
                    VStack {
                        switch selectedTab {
                        case 0:
                            detailsTab
                        case 1:
                            eventsTab
                        case 2:
                            reviewsTab
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPassPurchase) {
            PassPurchaseView(venue: venue)
        }
        .sheet(isPresented: $showingMenu) {
            VenueMenuView(venue: venue)
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .alert("Error", isPresented: Binding(
            get: { error != nil },
            set: { if !$0 { error = nil } }
        )) {
            Text(error?.localizedDescription ?? "An unknown error occurred")
        }
    }
    
    private var detailsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoRow(label: "Hours", value: "5:00 PM - 2:00 AM")
            InfoRow(label: "Phone", value: "(555) 123-4567")
            InfoRow(label: "Website", value: "www.example.com")
            InfoRow(label: "Capacity", value: "250 people")
            InfoRow(label: "Wait Time", value: "15 minutes", valueColor: .green)
        }
    }
    
    private var eventsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Upcoming Events")
                .font(.headline)
            
            ForEach(1...3, id: \.self) { index in
                EventRow(
                    title: "Event \(index)",
                    date: "Nov \(index + 10), 2023",
                    time: "8:00 PM"
                )
            }
        }
    }
    
    private var reviewsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Reviews")
                .font(.headline)
            
            ForEach(1...3, id: \.self) { index in
                ReviewRow(
                    author: "User \(index)",
                    rating: Double(3 + index % 3),
                    comment: "This is a great venue with amazing atmosphere and service.",
                    date: "Oct \(index + 10), 2023"
                )
            }
        }
    }
}

struct TabButton: View {
    let text: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(text)
                .font(.headline)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .foregroundColor(isSelected ? .blue : .gray)
                .overlay(
                    Rectangle()
                        .frame(height: 2)
                        .foregroundColor(isSelected ? .blue : .clear)
                        .offset(y: 12),
                    alignment: .bottom
                )
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
    }
}

struct EventRow: View {
    let title: String
    let date: String
    let time: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            
            HStack {
                Text(date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("•")
                    .foregroundColor(.secondary)
                
                Text(time)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ReviewRow: View {
    let author: String
    let rating: Double
    let comment: String
    let date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(author)
                    .font(.headline)
                
                Spacer()
                
                Text("\(rating, specifier: "%.1f") ⭐")
                    .font(.subheadline)
            }
            
            Text(comment)
                .font(.body)
                .padding(.vertical, 4)
            
            Text(date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// Preview provider
struct VenueDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VenueDetailView(venue: Venue(
            id: "venue1",
            name: "The Grand Ballroom",
            description: "A luxurious ballroom for elegant events",
            address: "123 Main Street, New York, NY",
            imageURL: URL(string: "https://example.com/venue1.jpg"),
            latitude: 40.7128,
            longitude: -74.0060,
            isPremium: true
        ))
    }
} 