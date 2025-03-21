import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.fomo.pr", category: "PaywallView")

struct PaywallView: View {
    @EnvironmentObject private var navigationCoordinator: PreviewNavigationCoordinator
    @StateObject private var viewModel: PaywallViewModel
    
    init(venue: Venue) {
        _viewModel = StateObject(wrappedValue: PaywallViewModel(venue: venue))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with venue image
                    headerView
                    
                    // Subscription options
                    subscriptionOptionsView
                    
                    // Benefits section
                    benefitsView
                    
                    // Terms and conditions
                    termsView
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("Premium Access")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Close") {
                    navigationCoordinator.dismissSheet()
                }
            )
            .alert(item: $viewModel.errorMessage) { error in
                Alert(
                    title: Text("Purchase Error"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .sheet(isPresented: $viewModel.showingSuccessView) {
                purchaseSuccessView
            }
            .onAppear {
                logger.debug("PaywallView appeared for venue: \(viewModel.venue.name)")
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            // Venue image
            if let imageURL = viewModel.venue.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(ProgressView())
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "building.2")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                    )
            }
            
            // Venue info
            VStack(alignment: .leading, spacing: 8) {
                Text(viewModel.venue.name)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(viewModel.venue.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Unlock premium features at this venue")
                    .font(.headline)
                    .padding(.top, 4)
            }
            .padding(.horizontal)
        }
    }
    
    private var subscriptionOptionsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Your Pass")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                ForEach(viewModel.subscriptionOptions) { option in
                    SubscriptionOptionCard(
                        option: option,
                        isSelected: viewModel.selectedOption?.id == option.id,
                        onSelect: {
                            viewModel.selectedOption = option
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var benefitsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Premium Benefits")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.benefits, id: \.self) { benefit in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 20))
                        
                        Text(benefit)
                            .font(.body)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var termsView: some View {
        VStack(spacing: 24) {
            Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                Task {
                    await viewModel.purchaseSubscription()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                } else {
                    Text("Purchase \(viewModel.selectedOption?.name ?? "Pass")")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.selectedOption != nil ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
            }
            .disabled(viewModel.selectedOption == nil || viewModel.isLoading)
            .padding(.horizontal)
        }
    }
    
    private var purchaseSuccessView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .padding()
            
            Text("Purchase Successful!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("You now have premium access to \(viewModel.venue.name)")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button(action: {
                viewModel.showingSuccessView = false
                navigationCoordinator.dismissSheet()
                // In a real app, this would navigate to the venue's premium content
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .padding(.top, 24)
        }
        .padding()
    }
}

struct SubscriptionOptionCard: View {
    let option: SubscriptionOption
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(option.name)
                    .font(.headline)
                
                Text(option.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(option.price.formatted(.currency(code: "USD")))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(isSelected ? Color.blue : Color.gray, lineWidth: 2)
                    .frame(width: 24, height: 24)
                
                if isSelected {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 16, height: 16)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                )
        )
        .onTapGesture {
            onSelect()
        }
    }
}

struct SubscriptionOption: Identifiable {
    let id: String
    let name: String
    let description: String
    let price: Decimal
    let duration: Int // in days
}

class PaywallViewModel: ObservableObject {
    @Published var venue: Venue
    @Published var selectedOption: SubscriptionOption?
    @Published var isLoading: Bool = false
    @Published var errorMessage: ErrorMessage?
    @Published var showingSuccessView: Bool = false
    
    let subscriptionOptions: [SubscriptionOption] = [
        SubscriptionOption(
            id: "day-pass",
            name: "Day Pass",
            description: "24-hour access to premium features",
            price: 9.99,
            duration: 1
        ),
        SubscriptionOption(
            id: "week-pass",
            name: "Week Pass",
            description: "7-day access to premium features",
            price: 29.99,
            duration: 7
        ),
        SubscriptionOption(
            id: "month-pass",
            name: "Month Pass",
            description: "30-day access to premium features",
            price: 79.99,
            duration: 30
        )
    ]
    
    let benefits: [String] = [
        "Skip the line at entry",
        "Access to exclusive menu items",
        "Priority seating and reservations",
        "Special event invitations",
        "Discounts on food and drinks"
    ]
    
    init(venue: Venue) {
        self.venue = venue
        self.selectedOption = subscriptionOptions.first
    }
    
    func purchaseSubscription() async {
        guard let selectedOption = selectedOption else {
            errorMessage = ErrorMessage(message: "Please select a subscription option")
            return
        }
        
        await MainActor.run {
            isLoading = true
        }
        
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            await MainActor.run {
                self.isLoading = false
                self.showingSuccessView = true
            }
        } catch {
            await MainActor.run {
                self.errorMessage = ErrorMessage(message: "Purchase failed: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }
}

#if DEBUG
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        PaywallView(venue: Venue.mockVenue)
            .environmentObject(PreviewNavigationCoordinator.shared)
            .preferredColorScheme(.dark)
    }
}
#endif 