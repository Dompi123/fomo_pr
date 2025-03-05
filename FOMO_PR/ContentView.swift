import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.fomo.pr", category: "ContentView")

struct ContentView: View {
    @EnvironmentObject private var navigationCoordinator: PreviewNavigationCoordinator
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                // First tab - Venues
                VenueListView()
                    .tabItem {
                        Label("Venues", systemImage: "building.2")
                    }
                    .tag(0)
                
                // Second tab - Passes
                PassesView()
                    .tabItem {
                        Label("Passes", systemImage: "ticket")
                    }
                    .tag(1)
                
                // Third tab - Profile
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(2)
            }
            .navigationTitle(tabTitle)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $navigationCoordinator.presentedSheet) { sheet in
                switch sheet {
                case .drinkMenu:
                    DrinkMenuView()
                case .checkout(let order):
                    CheckoutView(order: order)
                case .paywall(let venue):
                    PaywallView(venue: venue)
                }
            }
        }
        .onAppear {
            logger.debug("ContentView appeared")
        }
    }
    
    private var tabTitle: String {
        switch selectedTab {
        case 0:
            return "Venues"
        case 1:
            return "Passes"
        case 2:
            return "Profile"
        default:
            return ""
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PreviewNavigationCoordinator.shared)
            .preferredColorScheme(.dark)
    }
}
#endif 