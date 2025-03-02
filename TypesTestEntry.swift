import SwiftUI

// Add this to your app's main navigation or ContentView
struct TypesTestEntry: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: TypesTestView()) {
                    Text("Test Types Availability")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                Text("Click the button above to test if all required types are available in your app.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("Types Test")
        }
    }
}

// You can add this to your app's main view like this:
/*
struct ContentView: View {
    var body: some View {
        TabView {
            // Your existing tabs
            
            TypesTestEntry()
                .tabItem {
                    Label("Types Test", systemImage: "checkmark.circle")
                }
        }
    }
}
*/

#Preview {
    TypesTestEntry()
} 