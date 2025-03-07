import SwiftUI
import FOMO_PR  // Import for FOMOTheme (includes FOMOThemeExtensions)
// FOMOThemeExtensions is now part of FOMO_PR module - no separate import needed

struct ProfileView: View {
    @State private var name = "John Doe"
    @State private var email = "john.doe@example.com"
    
    var body: some View {
        Form {
            Section(header: Text("Personal Information").profileSectionStyle()) {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .profileAvatarStyle()
                    
                    VStack(alignment: .leading) {
                        Text(name)
                            .profileHeadingStyle()
                        Text(email)
                            .profileSubheadingStyle()
                    }
                }
                .profileRowStyle()
            }
            
            Section(header: Text("Account").profileSectionStyle()) {
                NavigationLink(destination: PlaceholderView()) {
                    Label("Payment Methods", systemImage: "creditcard")
                        .profileRowStyle()
                }
                
                NavigationLink(destination: PlaceholderView()) {
                    Label("Subscription", systemImage: "star")
                        .profileRowStyle()
                }
                
                NavigationLink(destination: PlaceholderView()) {
                    Label("Order History", systemImage: "bag")
                        .profileRowStyle()
                }
            }
            
            Section(header: Text("Preferences").profileSectionStyle()) {
                NavigationLink(destination: PlaceholderView()) {
                    Label("Notifications", systemImage: "bell")
                        .profileRowStyle()
                }
                
                NavigationLink(destination: PlaceholderView()) {
                    Label("Appearance", systemImage: "paintbrush")
                        .profileRowStyle()
                }
            }
            
            Section {
                Button(action: {}) {
                    Text("Sign Out")
                        .foregroundColor(FOMOTheme.Colors.error)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .profileRowStyle()
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
#endif 