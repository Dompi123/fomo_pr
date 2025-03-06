import SwiftUI
import FOMO_PR

#if ENABLE_PAYWALL || PREVIEW_MODE
struct PaywallView: View {
    @StateObject var viewModel: PaywallViewModel
    @EnvironmentObject var navigationCoordinator: PreviewNavigationCoordinator
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTier: PricingTier?
    @State private var showSuccess = false
    @State private var isLoading = false
    
    var isPaywallEnabled: Bool {
        #if ENABLE_PAYWALL
        return true
        #else
        return false
        #endif
    }
    
    var body: some View {
        if !isPaywallEnabled {
            VStack {
                Text("Paywall feature is disabled")
                    .font(.headline)
                    .padding()
                
                Text("Enable this feature by setting ENABLE_PAYWALL flag")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Go Back") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .padding()
            }
            .onAppear {
                print("DEBUG: Paywall feature is disabled, but view was opened.")
            }
        } else {
            NavigationView {
                ZStack {
                    if viewModel.isLoading {
                        VStack {
                            ProgressView()
                            Text("Loading pricing options...")
                                .padding()
                        }
                    } else if let error = viewModel.error {
                        VStack {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 50))
                                .foregroundColor(.red)
                                .padding()
                            
                            Text("Error: \(error.localizedDescription)")
                                .padding()
                            
                            Button("Try Again") {
                                viewModel.loadPricingTiers()
                            }
                            .buttonStyle(.bordered)
                        }
                    } else {
                        VStack {
                            Text("Select a Pass for \(viewModel.venue.name)")
                                .font(.headline)
                                .padding(.top)
                            
                            List(viewModel.pricingTiers, id: \.id) { tier in
                                PricingTierRow(tier: tier, isSelected: selectedTier?.id == tier.id)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        selectedTier = tier
                                    }
                            }
                            
                            Button(action: {
                                guard let selectedTier = selectedTier else { return }
                                isLoading = true
                                viewModel.processPurchase(tier: selectedTier) { result in
                                    isLoading = false
                                    switch result {
                                    case .success:
                                        showSuccess = true
                                    case .failure(let error):
                                        viewModel.error = error
                                    }
                                }
                            }) {
                                Text("Purchase Pass")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                            .background(selectedTier == nil ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding()
                            .disabled(selectedTier == nil)
                            
                            if isLoading {
                                ProgressView()
                                    .padding()
                            }
                        }
                    }
                }
                .navigationTitle("Buy Venue Pass")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
                .sheet(isPresented: $showSuccess) {
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("Purchase Successful!")
                            .font(.title)
                        
                        Text("Your pass for \(viewModel.venue.name) has been added to your account.")
                            .multilineTextAlignment(.center)
                            .padding()
                        
                        Button("Return to Venue") {
                            showSuccess = false
                            dismiss()
                        }
                        .buttonStyle(.bordered)
                        .padding()
                    }
                    .padding()
                }
                .onAppear {
                    viewModel.loadPricingTiers()
                }
            }
        }
    }
}

struct PricingTierRow: View {
    let tier: PricingTier
    let isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(tier.name)
                    .font(.headline)
                
                Text("$\(String(format: "%.2f", tier.price))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(tier.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
    }
}

#if DEBUG
struct PaywallView_Previews: PreviewProvider {
    static var previews: some View {
        let venue = Venue(id: "123", name: "Preview Venue", description: "A preview venue", location: "Somewhere", imageURL: nil, isPremium: false)
        let viewModel = PaywallViewModel(venue: venue)
        
        return PaywallView(viewModel: viewModel)
            .environmentObject(PreviewNavigationCoordinator())
    }
}
#endif
#endif 