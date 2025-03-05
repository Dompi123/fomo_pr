import SwiftUI

struct ProfileView: View {
    @State private var name = "John Doe"
    @State private var email = "john.doe@example.com"
    
    var body: some View {
        Form {
            Section(header: Text("Personal Information")) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading) {
                        Text(name)
                            .font(.headline)
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.vertical, 10)
            }
            
            Section(header: Text("Account")) {
                NavigationLink(destination: PlaceholderView()) {
                    Label("Payment Methods", systemImage: "creditcard")
                }
                
                NavigationLink(destination: PlaceholderView()) {
                    Label("Purchase History", systemImage: "bag")
                }
                
                NavigationLink(destination: PlaceholderView()) {
                    Label("Notifications", systemImage: "bell")
                }
            }
            
            Section(header: Text("App")) {
                NavigationLink(destination: PlaceholderView()) {
                    Label("Settings", systemImage: "gear")
                }
                
                NavigationLink(destination: PlaceholderView()) {
                    Label("Help & Support", systemImage: "questionmark.circle")
                }
                
                NavigationLink(destination: PlaceholderView()) {
                    Label("About", systemImage: "info.circle")
                }
            }
            
            Section {
                Button(action: {
                    // Sign out action
                }) {
                    Text("Sign Out")
                        .foregroundColor(.red)
                }
            }
        }
        .navigationTitle("Profile")
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileView()
        }
    }
}
#endif 
#endif 