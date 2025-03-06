import SwiftUI
import Foundation
import OSLog
// import Models // Commenting out Models import to use local implementations instead
// import Core // Commenting out Core import to use local implementations instead

struct VenueDetailView: View {
    let venue: Venue
    @EnvironmentObject var navigationCoordinator: PreviewNavigationCoordinator
    @State private var selectedTab = 0
    @State private var showingPaywall = false
    @State private var showingDrinkMenu = false
    @State private var isLoading = false
    @State private var error: Error?
    
    private let logger = Logger(subsystem: "com.fomo", category: "VenueDetail")
    
    var isPaywallEnabled: Bool {
        #if ENABLE_PAYWALL
        return true
        #else
        return false
        #endif
    }
    
    var isDrinkMenuEnabled: Bool {
        #if ENABLE_DRINK_MENU
        return true
        #else
        return false
        #endif
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Venue Image
                if let imageURLString = venue.imageURL, let imageURL = URL(string: imageURLString) {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .overlay(
                                ProgressView()
                            )
                    }
                    .frame(height: 240)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 240)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                        )
                }
                
                // Venue Info
                VStack(alignment: .leading, spacing: 12) {
                    Text(venue.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    if venue.isPremium {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Premium Venue")
                                .font(.subheadline)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Text(venue.location)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(venue.description)
                        .font(.body)
                        .padding(.top, 4)
                    
                    // Action Buttons
                    HStack(spacing: 20) {
                        Button(action: {
                            if isDrinkMenuEnabled {
                                navigationCoordinator.navigateToDrinkMenu(venue: venue)
                            } else {
                                print("Drink menu feature is disabled")
                            }
                        }) {
                            VStack {
                                Image(systemName: "wineglass")
                                    .font(.system(size: 24))
                                Text("View Menu")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .background(isDrinkMenuEnabled ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(!isDrinkMenuEnabled)
                        
                        Button(action: {
                            if isPaywallEnabled {
                                showingPaywall = true
                            } else {
                                print("Paywall feature is disabled")
                            }
                        }) {
                            VStack {
                                Image(systemName: "ticket")
                                    .font(.system(size: 24))
                                Text("Buy Pass")
                                    .font(.caption)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .background(isPaywallEnabled ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(!isPaywallEnabled)
                    }
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
        .navigationTitle("Venue Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPaywall) {
            #if ENABLE_PAYWALL
            PaywallView(viewModel: PaywallViewModel(venue: venue))
                .environmentObject(navigationCoordinator)
            #else
            Text("Paywall feature is disabled in this build")
                .padding()
            #endif
        }
        .sheet(isPresented: $showingDrinkMenu) {
            #if ENABLE_DRINK_MENU
            DrinkListView(venue: venue)
                .environmentObject(navigationCoordinator)
            #else
            Text("Drink menu is disabled in this build")
                .padding()
            #endif
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

#if DEBUG
struct VenueDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let previewVenue = Venue(
            id: "123",
            name: "Sample Venue",
            description: "This is a beautiful venue with great atmosphere and amazing food. Perfect for a night out with friends or a romantic date.",
            location: "123 Main St, City",
            imageURL: nil,
            isPremium: true
        )
        
        return NavigationView {
            VenueDetailView(venue: previewVenue)
                .environmentObject(PreviewNavigationCoordinator())
        }
    }
}
#endif 