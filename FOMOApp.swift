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
            
            // Second tab - Temporarily removed until ModuleTestView is implemented
            Text("Module Test Coming Soon")
                .tabItem {
                    Label("Module Test", systemImage: "gear")
                }
        }
    }
}

#Preview {
    MainContentView()
} 