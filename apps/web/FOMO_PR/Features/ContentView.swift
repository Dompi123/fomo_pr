import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.fomo.pr", category: "ContentView")

struct ContentView: View {
    @EnvironmentObject private var navigationCoordinator: PreviewNavigationCoordinator
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedTab) {
                VenueListView()
                    .tabItem {
                        Label("Venues", systemImage: "building.2")
                    }
                    .tag(0)
                
                PassesView()
                    .tabItem {
                        Label("My Passes", systemImage: "ticket")
                    }
                    .tag(1)
                
                ProfileView()
                    .tabItem {
                        Label("Profile", systemImage: "person")
                    }
                    .tag(2)
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $navigationCoordinator.presentedSheet) { sheet in
                logger.debug("Presenting sheet: \(sheet.id)")
                switch sheet {
                case .drinkMenu:
                    DrinkMenuView()
                        .environmentObject(navigationCoordinator)
                case .checkout(let order):
                    CheckoutView(order: order)
                        .environmentObject(navigationCoordinator)
                case .paywall(let venue):
                    PassPurchaseView(venue: venue)
                        .environmentObject(navigationCoordinator)
                }
            }
        }
        .environmentObject(navigationCoordinator)
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(PreviewNavigationCoordinator.shared)
    }
}
#endif
