import SwiftUI

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
            // First tab - Types Test
            TypesTestEntry()
                .tabItem {
                    Label("Types Test", systemImage: "checkmark.circle")
                }
            
            // Second tab - Home
            Text("Welcome to FOMO!")
                .font(.largeTitle)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
        }
    }
}

#Preview {
    MainContentView()
} 