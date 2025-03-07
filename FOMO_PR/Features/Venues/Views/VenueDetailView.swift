import SwiftUI
import Foundation
import OSLog
import FOMO_PR  // Import for FOMOTheme
// import Models // Commenting out Models import to use local implementations instead
// import Core // Commenting out Core import to use local implementations instead

// Remove separate import for theme extensions since it's part of FOMO_PR now
// import FOMOThemeExtensions

// MARK: - VenueDetail-specific Extensions
extension View {
    func venueTabButtonStyle(isSelected: Bool) -> some View {
        self.font(FOMOTheme.Typography.headline)
            .padding(.vertical, FOMOTheme.Spacing.small)
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? FOMOTheme.Colors.primary : FOMOTheme.Colors.textSecondary)
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isSelected ? FOMOTheme.Colors.primary : .clear)
                    .offset(y: 12),
                alignment: .bottom
            )
    }
    
    func venueInfoRowStyle() -> some View {
        self.padding(FOMOTheme.Spacing.small)
            .background(FOMOTheme.Colors.surface.opacity(0.1))
            .cornerRadius(FOMOTheme.Radius.small)
    }
}

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
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
                // Venue Image
                if let imageURL = venue.imageURL {
                    AsyncImage(url: imageURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(FOMOTheme.Colors.surface)
                            .overlay(
                                ProgressView()
                            )
                    }
                    .frame(height: 240)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(FOMOTheme.Colors.surface)
                        .frame(height: 240)
                        .overlay(
                            Image(systemName: "photo")
                                .font(FOMOTheme.Typography.largeTitle)
                                .foregroundColor(FOMOTheme.Colors.textSecondary)
                        )
                }
                
                // Venue Info
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text(venue.name)
                        .venueTitleStyle()
                    
                    if venue.isPremium {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(FOMOTheme.Colors.warning)
                            Text("Premium Venue")
                                .venueSubtitleStyle()
                                .foregroundColor(FOMOTheme.Colors.warning)
                        }
                    }
                    
                    Text(venue.address)
                        .venueSubtitleStyle()
                    
                    Text(venue.description)
                        .venueBodyStyle()
                        .padding(.top, FOMOTheme.Spacing.xxSmall)
                    
                    // Action Buttons
                    HStack(spacing: FOMOTheme.Spacing.medium) {
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
                                    .venueCaptionStyle()
                            }
                            .venueActionButtonStyle(isEnabled: isDrinkMenuEnabled)
                        }
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
                                    .venueCaptionStyle()
                            }
                            .venueActionButtonStyle(isEnabled: isPaywallEnabled)
                        }
                        .disabled(!isPaywallEnabled)
                    }
                    .padding(.top, FOMOTheme.Spacing.small)
                }
                .padding(.horizontal, FOMOTheme.Spacing.medium)
                
                // Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: FOMOTheme.Spacing.small) {
                        ForEach(["Popular", "Trending", "Live Music"], id: \.self) { tag in
                            Text(tag)
                                .venueTagStyle()
                        }
                    }
                    .padding(.horizontal, FOMOTheme.Spacing.medium)
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
                    .padding(.horizontal, FOMOTheme.Spacing.medium)
                    
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
                    .padding(FOMOTheme.Spacing.medium)
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
                .padding(FOMOTheme.Spacing.medium)
            #endif
        }
        .sheet(isPresented: $showingDrinkMenu) {
            #if ENABLE_DRINK_MENU
            DrinkListView()
                .environmentObject(navigationCoordinator)
            #else
            Text("Drink menu is disabled in this build")
                .padding(FOMOTheme.Spacing.medium)
            #endif
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(FOMOTheme.Colors.secondary.opacity(0.2))
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
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
            InfoRow(label: "Hours", value: "5:00 PM - 2:00 AM")
            InfoRow(label: "Phone", value: "(555) 123-4567")
            InfoRow(label: "Website", value: "www.example.com")
            InfoRow(label: "Capacity", value: "250 people")
            InfoRow(label: "Wait Time", value: "15 minutes", valueColor: FOMOTheme.Colors.success)
        }
    }
    
    private var eventsTab: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
            Text("Upcoming Events")
                .fomoHeadlineStyle()
            
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
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
            Text("Reviews")
                .fomoHeadlineStyle()
            
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
                .venueTabButtonStyle(isSelected: isSelected)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = FOMOTheme.Colors.text
    
    var body: some View {
        HStack {
            Text(label)
                .fomoCaptionStyle()
                .foregroundColor(FOMOTheme.Colors.textSecondary)
            
            Spacer()
            
            Text(value)
                .fomoBodyStyle()
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
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.xxSmall) {
            Text(title)
                .fomoHeadlineStyle()
            
            HStack {
                Text(date)
                    .fomoSubheadlineStyle()
                
                Text("•")
                    .foregroundColor(FOMOTheme.Colors.textSecondary)
                
                Text(time)
                    .fomoSubheadlineStyle()
            }
        }
        .padding(FOMOTheme.Spacing.medium)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FOMOTheme.Colors.surface)
        .fomoCornerRadius()
    }
}

struct ReviewRow: View {
    let author: String
    let rating: Double
    let comment: String
    let date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.xxSmall) {
            HStack {
                Text(author)
                    .fomoHeadlineStyle()
                
                Spacer()
                
                Text("\(rating, specifier: "%.1f") ⭐")
                    .fomoSubheadlineStyle()
                    .foregroundColor(FOMOTheme.Colors.warning)
            }
            
            Text(comment)
                .fomoBodyStyle()
                .padding(.vertical, FOMOTheme.Spacing.xxSmall)
            
            Text(date)
                .fomoCaptionStyle()
                .foregroundColor(FOMOTheme.Colors.textSecondary)
        }
        .padding(FOMOTheme.Spacing.medium)
        .background(FOMOTheme.Colors.surface)
        .fomoCornerRadius()
    }
}

#if DEBUG
struct VenueDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let previewVenue = Venue(
            id: "123",
            name: "Sample Venue",
            description: "This is a beautiful venue with great atmosphere and amazing food. Perfect for a night out with friends or a romantic date.",
            address: "123 Main St, City",
            imageURL: nil,
            latitude: 37.7749,
            longitude: -122.4194,
            isPremium: true
        )
        
        return NavigationView {
            VenueDetailView(venue: previewVenue)
                .environmentObject(PreviewNavigationCoordinator.shared)
        }
    }
}
#endif 