import SwiftUI
import OSLog
import FOMO_PR  // Import for FOMOTheme
import FOMOThemeExtensions

private let logger = Logger(subsystem: "com.fomo.pr", category: "PaywallView")

// MARK: - Additional Paywall-specific View Extensions
extension View {
    func paywallHeadingStyle() -> some View {
        self.fomoHeadlineStyle()
            .padding(.horizontal, FOMOTheme.Spacing.medium)
    }
    
    func paywallButtonStyle(isEnabled: Bool = true) -> some View {
        self.frame(maxWidth: .infinity)
            .padding()
            .background(isEnabled ? FOMOTheme.Colors.primary : FOMOTheme.Colors.textSecondary)
            .foregroundColor(FOMOTheme.Colors.text)
            .cornerRadius(FOMOTheme.Radius.medium)
            .padding(.horizontal, FOMOTheme.Spacing.medium)
    }
}

struct PaywallView: View {
    @EnvironmentObject private var navigationCoordinator: PreviewNavigationCoordinator
    @StateObject private var viewModel: PaywallViewModel
    
    init(venue: Venue) {
        _viewModel = StateObject(wrappedValue: PaywallViewModel(venue: venue))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: FOMOTheme.Spacing.large) {
                    // Header with venue image
                    headerView
                    
                    // Subscription options
                    subscriptionOptionsView
                    
                    // Benefits section
                    benefitsView
                    
                    // Terms and conditions
                    termsView
                }
                .padding(.bottom, FOMOTheme.Spacing.xxxLarge)
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
        VStack(spacing: FOMOTheme.Spacing.medium) {
            // Venue image
            if let imageURL = viewModel.venue.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(FOMOTheme.Colors.surface)
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
                            .fill(FOMOTheme.Colors.surface)
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "photo")
                                    .font(FOMOTheme.Typography.largeTitle)
                                    .foregroundColor(FOMOTheme.Colors.textSecondary)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Rectangle()
                    .fill(FOMOTheme.Colors.surface)
                    .frame(height: 200)
                    .overlay(
                        Image(systemName: "building.2")
                            .font(FOMOTheme.Typography.largeTitle)
                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                    )
            }
            
            // Venue info
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                Text(viewModel.venue.name)
                    .fomoTitle2Style()
                    .fontWeight(.bold)
                
                Text(viewModel.venue.description)
                    .fomoBodyStyle()
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("Unlock premium features at this venue")
                    .fomoHeadlineStyle()
                    .padding(.top, FOMOTheme.Spacing.xxSmall)
            }
            .padding(.horizontal, FOMOTheme.Spacing.medium)
        }
    }
    
    private var subscriptionOptionsView: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
            Text("Choose Your Pass")
                .paywallHeadingStyle()
            
            VStack(spacing: FOMOTheme.Spacing.medium) {
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
            .padding(.horizontal, FOMOTheme.Spacing.medium)
        }
    }
    
    private var benefitsView: some View {
        VStack(alignment: .leading, spacing: FOMOTheme.Spacing.medium) {
            Text("Premium Benefits")
                .paywallHeadingStyle()
            
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                ForEach(viewModel.benefits, id: \.self) { benefit in
                    HStack(alignment: .top, spacing: FOMOTheme.Spacing.small) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(FOMOTheme.Colors.success)
                            .font(.system(size: 20))
                        
                        Text(benefit)
                            .fomoBodyStyle()
                    }
                }
            }
            .padding(.horizontal, FOMOTheme.Spacing.medium)
        }
    }
    
    private var termsView: some View {
        VStack(spacing: FOMOTheme.Spacing.large) {
            Text("By continuing, you agree to our Terms of Service and Privacy Policy")
                .fomoCaptionStyle()
                .foregroundColor(FOMOTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, FOMOTheme.Spacing.medium)
            
            Button(action: {
                Task {
                    await viewModel.purchaseSubscription()
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .tint(FOMOTheme.Colors.text)
                        .paywallButtonStyle()
                } else {
                    Text("Purchase \(viewModel.selectedOption?.name ?? "Pass")")
                        .fomoHeadlineStyle()
                        .foregroundColor(FOMOTheme.Colors.text)
                        .paywallButtonStyle(isEnabled: viewModel.selectedOption != nil)
                }
            }
            .disabled(viewModel.selectedOption == nil || viewModel.isLoading)
        }
    }
    
    private var purchaseSuccessView: some View {
        VStack(spacing: FOMOTheme.Spacing.large) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(FOMOTheme.Colors.success)
                .padding()
            
            Text("Purchase Successful!")
                .fomoTitle1Style()
                .fontWeight(.bold)
            
            Text("You now have premium access to \(viewModel.venue.name)")
                .fomoBodyStyle()
                .multilineTextAlignment(.center)
                .padding(.horizontal, FOMOTheme.Spacing.medium)
            
            Button(action: {
                viewModel.showingSuccessView = false
                navigationCoordinator.dismissSheet()
                // In a real app, this would navigate to the venue's premium content
            }) {
                Text("Continue")
                    .fomoHeadlineStyle()
                    .paywallButtonStyle()
            }
            .padding(.top, FOMOTheme.Spacing.large)
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
            VStack(alignment: .leading, spacing: FOMOTheme.Spacing.small) {
                Text(option.name)
                    .fomoHeadlineStyle()
                
                Text(option.description)
                    .fomoSubheadlineStyle()
                
                Text(option.price.formatted(.currency(code: "USD")))
                    .fomoTextStyle(FOMOTheme.Typography.title3)
                    .fontWeight(.bold)
            }
            
            Spacer()
            
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundColor(isSelected ? FOMOTheme.Colors.primary : FOMOTheme.Colors.textSecondary)
        }
        .padding(FOMOTheme.Spacing.medium)
        .background(isSelected ? FOMOTheme.Colors.primary.opacity(0.1) : FOMOTheme.Colors.surface)
        .fomoCornerRadius()
        .overlay(
            RoundedRectangle(cornerRadius: FOMOTheme.Radius.medium)
                .stroke(isSelected ? FOMOTheme.Colors.primary : FOMOTheme.Colors.textSecondary.opacity(0.3), lineWidth: 1)
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
        let venue = Venue(
            id: "venue1",
            name: "The Rooftop Bar",
            description: "A trendy rooftop bar with amazing city views and craft cocktails.",
            address: "123 Main St, New York, NY 10001",
            imageURL: nil,
            rating: 4.7,
            isPremium: true
        )
        
        return PaywallView(venue: venue)
            .environmentObject(PreviewNavigationCoordinator.shared)
    }
}
#endif 