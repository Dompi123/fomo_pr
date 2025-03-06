import SwiftUI
import os.log

// Feature flags
#if ENABLE_PAYWALL
let isPaywallEnabled = true
#else
let isPaywallEnabled = false
#endif

#if ENABLE_DRINK_MENU
let isDrinkMenuEnabled = true
#else
let isDrinkMenuEnabled = false
#endif

#if ENABLE_CHECKOUT
let isCheckoutEnabled = true
#else
let isCheckoutEnabled = false
#endif

#if ENABLE_SEARCH
let isSearchEnabled = true
#else
let isSearchEnabled = false
#endif

#if ENABLE_PREMIUM_VENUES
let isPremiumVenuesEnabled = true
#else
let isPremiumVenuesEnabled = false
#endif

#if ENABLE_MOCK_DATA
let isMockDataEnabled = true
#else
let isMockDataEnabled = false
#endif

#if PREVIEW_MODE
let isPreviewMode = true
#else
let isPreviewMode = false
#endif

// Logger
let logger = Logger(subsystem: "com.fomo", category: "App")

// Navigation
enum Sheet: Identifiable {
    case profile
    case settings
    case payment
    case drinkDetails(Drink)
    case checkout(DrinkOrder, Venue)
    case paywall(Venue)
    case drinkMenu(Venue)
    
    var id: String {
        switch self {
        case .profile:
            return "profile"
        case .settings:
            return "settings"
        case .payment:
            return "payment"
        case .drinkDetails(let drink):
            return "drinkDetails-\(drink.id)"
        case .checkout(let order, _):
            return "checkout-\(order.id)"
        case .paywall(let venue):
            return "paywall-\(venue.id)"
        case .drinkMenu(let venue):
            return "drinkMenu-\(venue.id)"
        }
    }
}

class PreviewNavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()
    @Published var activeSheet: Sheet?
    @Published var selectedTab: Int = 0
    
    func navigateToVenueDetail(venue: Venue) {
        path.append(venue)
    }
    
    func navigateToDrinkMenu(venue: Venue) {
        if isDrinkMenuEnabled {
            activeSheet = .drinkMenu(venue)
        } else {
            logger.warning("Attempted to navigate to drink menu when feature is disabled")
        }
    }
    
    func navigateToPaywall(venue: Venue) {
        if isPaywallEnabled {
            activeSheet = .paywall(venue)
        } else {
            logger.warning("Attempted to navigate to paywall when feature is disabled")
        }
    }
    
    func navigateToCheckout(order: DrinkOrder, venue: Venue) {
        if isCheckoutEnabled {
            activeSheet = .checkout(order, venue)
        } else {
            logger.warning("Attempted to navigate to checkout when feature is disabled")
        }
    }
    
    func navigateToProfile() {
        activeSheet = .profile
    }
    
    func navigateToSettings() {
        activeSheet = .settings
    }
    
    func goBack() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func dismissSheet() {
        activeSheet = nil
    }
}

// Payment
class PaymentManager: ObservableObject {
    @Published var isProcessing = false
    @Published var lastError: Error?
    
    func processPayment(amount: Double, completion: @escaping (Result<String, Error>) -> Void) {
        guard isPaywallEnabled else {
            completion(.failure(NSError(domain: "com.fomo", code: 400, userInfo: [NSLocalizedDescriptionKey: "Payment feature is disabled"])))
            return
        }
        
        isProcessing = true
        
        // Simulate payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isProcessing = false
            
            // Simulate success (90% of the time)
            if Double.random(in: 0...1) < 0.9 {
                let transactionId = UUID().uuidString
                completion(.success(transactionId))
            } else {
                // Simulate error
                let error = NSError(domain: "com.fomo", code: 500, userInfo: [NSLocalizedDescriptionKey: "Payment processing failed. Please try again."])
                self.lastError = error
                completion(.failure(error))
            }
        }
    }
}

// Mock Data Provider
class MockDataProvider {
    static let shared = MockDataProvider()
    
    func getVenues() -> [Venue] {
        return [
            Venue(
                id: "venue1",
                name: "The Grand Ballroom",
                description: "A luxurious ballroom for elegant events with stunning architecture and premium amenities.",
                location: "123 Main Street, New York, NY",
                imageURL: nil,
                isPremium: true
            ),
            Venue(
                id: "venue2",
                name: "Skyline Lounge",
                description: "Rooftop lounge with panoramic city views, craft cocktails, and a sophisticated atmosphere.",
                location: "456 Park Avenue, New York, NY",
                imageURL: nil,
                isPremium: false
            ),
            Venue(
                id: "venue3",
                name: "The Basement",
                description: "Underground club featuring live music, DJ sets, and an intimate dance floor.",
                location: "789 Broadway, New York, NY",
                imageURL: nil,
                isPremium: false
            ),
            Venue(
                id: "venue4",
                name: "Waterfront Pavilion",
                description: "Open-air venue on the water with beautiful sunset views and spacious seating.",
                location: "101 Harbor Drive, New York, NY",
                imageURL: nil,
                isPremium: true
            ),
            Venue(
                id: "venue5",
                name: "The Loft",
                description: "Industrial-chic space with exposed brick, perfect for art shows and creative events.",
                location: "202 SoHo Street, New York, NY",
                imageURL: nil,
                isPremium: false
            )
        ]
    }
    
    func getDrinks() -> [Drink] {
        return [
            Drink(
                id: "drink1",
                name: "Mojito",
                description: "Classic cocktail with rum, mint, lime, and sugar",
                price: 12.99,
                imageURL: nil,
                available: true
            ),
            Drink(
                id: "drink2",
                name: "Margarita",
                description: "Tequila cocktail with lime juice and orange liqueur",
                price: 14.99,
                imageURL: nil,
                available: true
            ),
            Drink(
                id: "drink3",
                name: "Old Fashioned",
                description: "Classic whiskey cocktail with bitters and sugar",
                price: 15.99,
                imageURL: nil,
                available: true
            ),
            Drink(
                id: "drink4",
                name: "Sparkling Water",
                description: "Refreshing sparkling water with lime",
                price: 4.99,
                imageURL: nil,
                available: true
            ),
            Drink(
                id: "drink5",
                name: "Craft Beer",
                description: "Local IPA with notes of citrus and pine",
                price: 8.99,
                imageURL: nil,
                available: true
            )
        ]
    }
    
    func getPricingTiers() -> [PricingTier] {
        return [
            PricingTier(
                id: "tier1",
                name: "Basic Pass",
                description: "Standard entry to the venue",
                price: 19.99,
                features: ["Entry to main areas", "Access to basic amenities"]
            ),
            PricingTier(
                id: "tier2",
                name: "Premium Pass",
                description: "Enhanced experience with additional perks",
                price: 39.99,
                features: ["Entry to all areas", "Priority entry", "One complimentary drink", "Access to premium amenities"]
            ),
            PricingTier(
                id: "tier3",
                name: "VIP Pass",
                description: "Ultimate luxury experience",
                price: 79.99,
                features: ["Entry to all areas including VIP lounge", "Priority entry with no wait", "Three complimentary drinks", "Access to all amenities", "Personal concierge service"]
            )
        ]
    }
}

// Main App View
struct RootView: View {
    @StateObject private var navigationCoordinator = PreviewNavigationCoordinator()
    @StateObject private var paymentManager = PaymentManager()
    
    var body: some View {
        NavigationStack(path: $navigationCoordinator.path) {
            TabView(selection: $navigationCoordinator.selectedTab) {
                // Venues Tab
                VenueListView()
                    .tabItem {
                        Label("Venues", systemImage: "building.2")
                    }
                    .tag(0)
                
                // Passes Tab
                PassesView()
                    .tabItem {
                        Label("My Passes", systemImage: "ticket")
                    }
                    .tag(1)
                
                // Profile Tab
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(2)
            }
            .navigationDestination(for: Venue.self) { venue in
                VenueDetailView(venue: venue)
            }
        }
        .sheet(item: $navigationCoordinator.activeSheet) { sheet in
            switch sheet {
            case .profile:
                ProfileView()
            case .settings:
                Text("Settings")
            case .payment:
                Text("Payment")
            case .drinkDetails(let drink):
                if let viewModel = DrinkListViewModel() as? DrinkListViewModel {
                    DrinkDetailView(drink: drink, viewModel: viewModel)
                        .environmentObject(navigationCoordinator)
                }
            case .checkout(let order, let venue):
                #if ENABLE_CHECKOUT
                CheckoutView(order: order, venue: venue)
                    .environmentObject(navigationCoordinator)
                #else
                Text("Checkout is disabled in this build")
                #endif
            case .paywall(let venue):
                #if ENABLE_PAYWALL
                PaywallView(viewModel: PaywallViewModel(venue: venue))
                    .environmentObject(navigationCoordinator)
                #else
                Text("Paywall is disabled in this build")
                #endif
            case .drinkMenu(let venue):
                #if ENABLE_DRINK_MENU
                DrinkListView(venue: venue)
                    .environmentObject(navigationCoordinator)
                #else
                Text("Drink menu is disabled in this build")
                #endif
            }
        }
        .environmentObject(navigationCoordinator)
        .environmentObject(paymentManager)
        .onAppear {
            logger.info("App started with feature flags: Paywall: \(isPaywallEnabled), DrinkMenu: \(isDrinkMenuEnabled), Checkout: \(isCheckoutEnabled), Search: \(isSearchEnabled), PremiumVenues: \(isPremiumVenuesEnabled), MockData: \(isMockDataEnabled), PreviewMode: \(isPreviewMode)")
        }
    }
}

// Placeholder Views
struct VenueListView: View {
    @EnvironmentObject var navigationCoordinator: PreviewNavigationCoordinator
    @State private var venues: [Venue] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            if isLoading {
                ProgressView("Loading venues...")
            } else if venues.isEmpty {
                VStack {
                    Image(systemName: "building.2.slash")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("No venues available")
                        .font(.headline)
                }
            } else {
                List(venues) { venue in
                    VenueRow(venue: venue)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            navigationCoordinator.navigateToVenueDetail(venue: venue)
                        }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Venues")
        .onAppear {
            loadVenues()
        }
    }
    
    private func loadVenues() {
        isLoading = true
        
        // In a real app, we would load from API
        #if PREVIEW_MODE || ENABLE_MOCK_DATA
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.venues = MockDataProvider.shared.getVenues()
            self.isLoading = false
        }
        #else
        // Set empty venues for real app without API implementation
        self.venues = []
        self.isLoading = false
        #endif
    }
}

struct VenueRow: View {
    let venue: Venue
    
    var body: some View {
        HStack {
            if let imageURLString = venue.imageURL, let imageURL = URL(string: imageURLString) {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 80, height: 80)
                        .cornerRadius(8)
                }
            } else {
                Image(systemName: "building.2")
                    .font(.system(size: 40))
                    .foregroundColor(.gray)
                    .frame(width: 80, height: 80)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(venue.name)
                    .font(.headline)
                
                Text(venue.location)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if venue.isPremium {
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text("Premium")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

struct PassesView: View {
    var body: some View {
        VStack {
            Image(systemName: "ticket")
                .font(.system(size: 50))
                .foregroundColor(.gray)
                .padding()
            
            Text("No passes yet")
                .font(.headline)
            
            Text("Your purchased passes will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        }
        .navigationTitle("My Passes")
    }
}

struct ProfileView: View {
    @EnvironmentObject var navigationCoordinator: PreviewNavigationCoordinator
    
    var body: some View {
        VStack {
            Image(systemName: "person.circle")
                .font(.system(size: 80))
                .foregroundColor(.gray)
                .padding()
            
            Text("John Doe")
                .font(.title)
            
            Text("john.doe@example.com")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Divider()
                .padding(.vertical)
            
            Button(action: {
                navigationCoordinator.navigateToSettings()
            }) {
                HStack {
                    Image(systemName: "gear")
                    Text("Settings")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("Profile")
    }
}

// Main App
@main
struct FOMOApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
        }
    }
}
