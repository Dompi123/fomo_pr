import SwiftUI
import Foundation
import OSLog

// MARK: - VenueDetail-specific Extensions
extension View {
    func venueTabButtonStyle(isSelected: Bool) -> some View {
        self.font(FOMOTheme.subtitleFont)
            .padding(.vertical, FOMOTheme.smallPadding)
            .frame(maxWidth: .infinity)
            .foregroundColor(isSelected ? FOMOTheme.primaryColor : FOMOTheme.lightTextColor)
            .overlay(
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isSelected ? FOMOTheme.primaryColor : .clear)
                    .offset(y: 12),
                alignment: .bottom
            )
    }
    
    func venueInfoRowStyle() -> some View {
        self.padding(FOMOTheme.smallPadding)
            .background(FOMOTheme.backgroundColor.opacity(0.1))
            .cornerRadius(FOMOTheme.cornerRadius)
    }
    
    func venueTitleStyle() -> some View {
        self.font(FOMOTheme.titleFont)
            .foregroundColor(FOMOTheme.textColor)
    }
    
    func venueSubtitleStyle() -> some View {
        self.font(FOMOTheme.subtitleFont)
            .foregroundColor(FOMOTheme.lightTextColor)
    }
    
    func venueBodyStyle() -> some View {
        self.font(FOMOTheme.bodyFont)
            .foregroundColor(FOMOTheme.textColor)
    }
    
    func venueCaptionStyle() -> some View {
        self.font(FOMOTheme.smallFont)
            .foregroundColor(FOMOTheme.textColor)
    }
    
    func venueTagStyle() -> some View {
        self.font(FOMOTheme.smallFont)
            .padding(.horizontal, FOMOTheme.smallPadding)
            .padding(.vertical, 4)
            .background(FOMOTheme.primaryColor.opacity(0.1))
            .foregroundColor(FOMOTheme.primaryColor)
            .cornerRadius(FOMOTheme.cornerRadius)
    }
    
    func venueActionButtonStyle(isEnabled: Bool) -> some View {
        self.padding(FOMOTheme.smallPadding)
            .frame(maxWidth: .infinity)
            .background(isEnabled ? FOMOTheme.primaryColor : FOMOTheme.lightTextColor)
            .foregroundColor(.white)
            .cornerRadius(FOMOTheme.cornerRadius)
            .opacity(isEnabled ? 1.0 : 0.5)
    }
}

// MARK: - InfoRow View
struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary
    
    var body: some View {
        HStack {
            Text(label)
                .font(FOMOTheme.smallFont)
                .foregroundColor(Color.secondary)
            
            Spacer()
            
            Text(value)
                .font(FOMOTheme.bodyFont)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
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
        FeatureManager.shared.isEnabled(.paywall)
    }
    
    var isDrinkMenuEnabled: Bool {
        FeatureManager.shared.isEnabled(.drinkMenu)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FOMOTheme.padding) {
                // Venue Image
                if let imageURL = venue.imageURL {
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
                                .foregroundColor(Color.gray)
                        )
                }
                
                // Venue Info
                VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                    Text(venue.name)
                        .font(FOMOTheme.Typography.headlineLarge)
                        .foregroundColor(FOMOTheme.Colors.text)
                        .popInEffect()
                    
                    if venue.isPremium {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Premium Venue")
                                .font(FOMOTheme.Typography.subheadline)
                                .foregroundColor(.yellow)
                        }
                        .padding(.horizontal, FOMOTheme.Spacing.small)
                        .padding(.vertical, 4)
                        .background(Color.yellow.opacity(0.15))
                        .cornerRadius(FOMOTheme.Radius.small)
                        .popInEffect()
                    }
                    
                    Text(venue.address)
                        .font(FOMOTheme.Typography.subheadline)
                        .foregroundColor(FOMOTheme.Colors.textSecondary)
                        .padding(.top, FOMOTheme.Spacing.xxSmall)
                    
                    Text(venue.description)
                        .font(FOMOTheme.Typography.body)
                        .foregroundColor(FOMOTheme.Colors.text)
                        .padding(.top, FOMOTheme.Spacing.small)
                    
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
                                    .font(FOMOTheme.Typography.caption1)
                            }
                            .padding(FOMOTheme.Spacing.small)
                            .frame(maxWidth: .infinity)
                            .background(isDrinkMenuEnabled ? FOMOTheme.Colors.primary : FOMOTheme.Colors.textSecondary)
                            .foregroundColor(.white)
                            .cornerRadius(FOMOTheme.Radius.button)
                            .themeShadow(FOMOTheme.Shadow.elevation2)
                            .pressEffect()
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
                                    .font(FOMOTheme.Typography.caption1)
                            }
                            .padding(FOMOTheme.Spacing.small)
                            .frame(maxWidth: .infinity)
                            .background(isPaywallEnabled ? FOMOTheme.Colors.accent : FOMOTheme.Colors.textSecondary)
                            .foregroundColor(.white)
                            .cornerRadius(FOMOTheme.Radius.button)
                            .themeShadow(FOMOTheme.Shadow.elevation2)
                            .pressEffect()
                        }
                        .disabled(!isPaywallEnabled)
                    }
                    .padding(.top, FOMOTheme.Spacing.medium)
                }
                .padding(.horizontal, FOMOTheme.Spacing.medium)
                .padding(.top, FOMOTheme.Spacing.medium)
                
                // Tags
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: FOMOTheme.Spacing.small) {
                        ForEach(["Popular", "Trending", "Live Music"], id: \.self) { tag in
                            Text(tag)
                                .font(FOMOTheme.Typography.caption1)
                                .padding(.horizontal, FOMOTheme.Spacing.small)
                                .padding(.vertical, 4)
                                .background(FOMOTheme.Colors.primary.opacity(0.1))
                                .foregroundColor(FOMOTheme.Colors.primary)
                                .cornerRadius(FOMOTheme.Radius.chip)
                        }
                    }
                    .padding(.horizontal, FOMOTheme.Spacing.medium)
                    .padding(.vertical, FOMOTheme.Spacing.small)
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
                    .padding(.horizontal, FOMOTheme.padding)
                    
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
                    .padding(FOMOTheme.padding)
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
                .padding(FOMOTheme.padding)
            #endif
        }
        .sheet(isPresented: $showingDrinkMenu) {
            #if ENABLE_DRINK_MENU
            DrinkListView()
                .environmentObject(navigationCoordinator)
            #else
            Text("Drink menu is disabled in this build")
                .padding(FOMOTheme.padding)
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
        VStack(alignment: .leading, spacing: FOMOTheme.padding) {
            InfoRow(label: "Hours", value: "5:00 PM - 2:00 AM")
            InfoRow(label: "Phone", value: "(555) 123-4567")
            InfoRow(label: "Website", value: "www.example.com")
            InfoRow(label: "Capacity", value: "250 people")
            InfoRow(label: "Wait Time", value: "15 minutes", valueColor: FOMOTheme.primaryColor)
        }
    }
    
    private var eventsTab: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.padding) {
            Text("Upcoming Events")
                .font(FOMOTheme.subtitleFont)
            
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
        VStack(alignment: .leading, spacing: FOMOTheme.padding) {
            Text("Reviews")
                .font(FOMOTheme.subtitleFont)
            
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

struct EventRow: View {
    let title: String
    let date: String
    let time: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.smallPadding / 2) {
            Text(title)
                .font(FOMOTheme.subtitleFont)
            
            HStack {
                Text(date)
                    .font(FOMOTheme.smallFont)
                    .foregroundColor(FOMOTheme.lightTextColor)
                
                Text("•")
                    .foregroundColor(FOMOTheme.lightTextColor)
                
                Text(time)
                    .font(FOMOTheme.smallFont)
                    .foregroundColor(FOMOTheme.lightTextColor)
            }
        }
        .padding(FOMOTheme.padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(FOMOTheme.backgroundColor)
        .cornerRadius(FOMOTheme.cornerRadius)
    }
}

struct ReviewRow: View {
    let author: String
    let rating: Double
    let comment: String
    let date: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.smallPadding / 2) {
            HStack {
                Text(author)
                    .font(FOMOTheme.subtitleFont)
                
                Spacer()
                
                Text("\(rating, specifier: "%.1f") ⭐")
                    .font(FOMOTheme.smallFont)
                    .foregroundColor(.yellow)
            }
            
            Text(comment)
                .font(FOMOTheme.bodyFont)
                .padding(.vertical, FOMOTheme.smallPadding / 2)
            
            Text(date)
                .font(FOMOTheme.smallFont)
                .foregroundColor(FOMOTheme.lightTextColor)
        }
        .padding(FOMOTheme.padding)
        .background(FOMOTheme.backgroundColor)
        .cornerRadius(FOMOTheme.cornerRadius)
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
            rating: 4.5,
            isPremium: true
        )
        
        return NavigationView {
            VenueDetailView(venue: previewVenue)
                .environmentObject(PreviewNavigationCoordinator.shared)
        }
    }
}
#endif 