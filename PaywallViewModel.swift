import Foundation
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.fomo.pr", category: "PaywallViewModel")

struct SubscriptionOption: Identifiable {
    let id: String
    let name: String
    let description: String
    let price: Decimal
    let duration: Int // in days
}

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
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
        logger.debug("Initialized PaywallViewModel for venue: \(venue.name)")
        self.selectedOption = subscriptionOptions.first
    }
    
    func purchaseSubscription() async {
        guard let selectedOption = selectedOption else {
            errorMessage = ErrorMessage(message: "Please select a subscription option")
            return
        }
        
        await MainActor.run {
            isLoading = true
            logger.debug("Processing purchase for \(selectedOption.name) at \(selectedOption.price) USD")
        }
        
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            // Simulate success/failure (90% success rate)
            let isSuccess = Double.random(in: 0...1) < 0.9
            
            if !isSuccess {
                throw NSError(domain: "PaywallError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Payment processing failed. Please try again."])
            }
            
            await MainActor.run {
                self.isLoading = false
                self.showingSuccessView = true
                logger.debug("Purchase successful for venue: \(venue.name), option: \(selectedOption.name)")
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
                self.errorMessage = ErrorMessage(message: error.localizedDescription)
                logger.error("Purchase failed: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Preview Helpers
extension PaywallViewModel {
    static var preview: PaywallViewModel {
        let venue = Venue(
            id: "venue-123",
            name: "The Rooftop Bar",
            description: "A trendy rooftop bar with amazing city views and craft cocktails.",
            address: "123 Main St, New York, NY 10001",
            imageURL: nil,
            latitude: 40.7128,
            longitude: -74.0060,
            isPremium: true
        )
        
        return PaywallViewModel(venue: venue)
    }
} 