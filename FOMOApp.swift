import SwiftUI
import Models
import Core

@main
struct FOMOApp: App {
    var body: some Scene {
        WindowGroup {
            MainContentView()
        }
    }
}

struct MainContentView: View {
    var body: some View {
        TabView {
            // Venues Tab
            NavigationView {
                VenueListView()
            }
            .tabItem {
                Label("Venues", systemImage: "building.2")
            }
            
            // Drinks Tab
            Text("Drinks Coming Soon")
                .tabItem {
                    Label("Drinks", systemImage: "wineglass")
                }
            
            // Passes Tab
            Text("Passes Coming Soon")
                .tabItem {
                    Label("Passes", systemImage: "ticket")
                }
            
            // Orders Tab
            Text("Orders Coming Soon")
                .tabItem {
                    Label("Orders", systemImage: "bag")
                }
            
            // Profile Tab
            Text("Profile Coming Soon")
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
            
            // For debugging - keep the Types Test accessible
            TypesTestEntry()
                .tabItem {
                    Label("Debug", systemImage: "ladybug")
                }
        }
    }
}

#Preview {
    MainContentView()
} 