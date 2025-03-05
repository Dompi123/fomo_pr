import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.fomo.pr", category: "ProfileView")

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var isEditingProfile = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile header
                VStack(spacing: 16) {
                    // Profile image
                    ZStack(alignment: .bottomTrailing) {
                        if let profileImage = viewModel.profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                                .shadow(radius: 3)
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 120, height: 120)
                                .foregroundColor(.gray)
                        }
                        
                        Button(action: {
                            logger.debug("Edit profile image tapped")
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.blue)
                                .background(Color(.systemBackground))
                                .clipShape(Circle())
                        }
                    }
                    
                    // User name and email
                    VStack(spacing: 4) {
                        Text(viewModel.user.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(viewModel.user.email)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Edit profile button
                    Button(action: {
                        isEditingProfile = true
                        logger.debug("Edit profile button tapped")
                    }) {
                        Text("Edit Profile")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // Membership section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Membership")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        // Membership type
                        HStack {
                            Label("Membership Type", systemImage: "star.fill")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(viewModel.user.membershipType)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        
                        Divider()
                            .padding(.leading)
                        
                        // Member since
                        HStack {
                            Label("Member Since", systemImage: "calendar")
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Text(viewModel.user.memberSince.formatted(date: .abbreviated, time: .omitted))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                    }
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Settings section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Settings")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 0) {
                        // Notifications
                        Toggle(isOn: $viewModel.notificationsEnabled) {
                            Label("Notifications", systemImage: "bell.fill")
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .onChange(of: viewModel.notificationsEnabled) { newValue in
                            logger.debug("Notifications toggled: \(newValue)")
                            viewModel.updateNotificationSettings()
                        }
                        
                        Divider()
                            .padding(.leading)
                        
                        // Dark mode
                        Toggle(isOn: $viewModel.darkModeEnabled) {
                            Label("Dark Mode", systemImage: "moon.fill")
                                .foregroundColor(.primary)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .onChange(of: viewModel.darkModeEnabled) { newValue in
                            logger.debug("Dark mode toggled: \(newValue)")
                            viewModel.updateAppearanceSettings()
                        }
                    }
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Sign out button
                Button(action: {
                    logger.debug("Sign out button tapped")
                    viewModel.signOut()
                }) {
                    Text("Sign Out")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .sheet(isPresented: $isEditingProfile) {
            EditProfileView(user: viewModel.user) { updatedUser in
                viewModel.updateProfile(with: updatedUser)
                isEditingProfile = false
            }
        }
        .onAppear {
            logger.debug("ProfileView appeared")
            viewModel.loadUserProfile()
        }
    }
}

struct EditProfileView: View {
    let user: User
    let onSave: (User) -> Void
    
    @State private var name: String
    @State private var email: String
    @State private var phone: String
    @Environment(\.presentationMode) private var presentationMode
    
    init(user: User, onSave: @escaping (User) -> Void) {
        self.user = user
        self.onSave = onSave
        _name = State(initialValue: user.name)
        _email = State(initialValue: user.email)
        _phone = State(initialValue: user.phone ?? "")
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("Name", text: $name)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    var updatedUser = user
                    updatedUser.name = name
                    updatedUser.email = email
                    updatedUser.phone = phone.isEmpty ? nil : phone
                    onSave(updatedUser)
                }
                .disabled(name.isEmpty || email.isEmpty)
            )
        }
    }
}

struct User {
    var id: String
    var name: String
    var email: String
    var phone: String?
    var membershipType: String
    var memberSince: Date
    
    static var mock: User {
        User(
            id: UUID().uuidString,
            name: "Alex Johnson",
            email: "alex.johnson@example.com",
            phone: "555-123-4567",
            membershipType: "Premium",
            memberSince: Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        )
    }
}

class ProfileViewModel: ObservableObject {
    @Published var user: User = User.mock
    @Published var profileImage: UIImage?
    @Published var notificationsEnabled: Bool = true
    @Published var darkModeEnabled: Bool = true
    
    func loadUserProfile() {
        // In a real app, this would load the user profile from a data source
        // For now, we'll use mock data
        self.user = User.mock
        
        // Simulate loading profile image
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // In a real app, this would load the user's profile image
            // For now, we'll leave it nil to show the placeholder
        }
    }
    
    func updateProfile(with updatedUser: User) {
        // In a real app, this would update the user profile in a data source
        self.user = updatedUser
    }
    
    func updateNotificationSettings() {
        // In a real app, this would update notification settings
    }
    
    func updateAppearanceSettings() {
        // In a real app, this would update appearance settings
    }
    
    func signOut() {
        // In a real app, this would sign the user out
    }
}

#if DEBUG
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
            .preferredColorScheme(.dark)
    }
}
#endif 