import Foundation
import SwiftUI

// MARK: - Models

enum PassStatus: String, Codable {
    case active
    case expired
    case pending
    case cancelled
}

struct Pass: Identifiable {
    let id: String
    let name: String
    let venueId: String
    let eventDate: Date
    let status: PassStatus
    let price: Double
    let purchaseDate: Date
    let expirationDate: Date
    let qrCode: String
}

// MARK: - View Model

final class PassesViewModel: ObservableObject {
    @Published var passes: [Pass] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?
    
    init() {
        loadPasses()
    }
    
    func loadPasses() {
        isLoading = true
        error = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.passes = [
                Pass(
                    id: "pass1",
                    name: "Weekend Pass - The Rooftop Bar",
                    venueId: "venue1",
                    eventDate: Date().addingTimeInterval(86400), // Tomorrow
                    status: .active,
                    price: 29.99,
                    purchaseDate: Date().addingTimeInterval(-3600), // 1 hour ago
                    expirationDate: Date().addingTimeInterval(172800), // 2 days from now
                    qrCode: "QR123456789"
                ),
                Pass(
                    id: "pass2",
                    name: "VIP Access - Club Neon",
                    venueId: "venue2",
                    eventDate: Date().addingTimeInterval(172800), // 2 days from now
                    status: .pending,
                    price: 49.99,
                    purchaseDate: Date().addingTimeInterval(-1800), // 30 minutes ago
                    expirationDate: Date().addingTimeInterval(259200), // 3 days from now
                    qrCode: "QR987654321"
                ),
                Pass(
                    id: "pass3",
                    name: "Jazz Night - Jazz Lounge",
                    venueId: "venue3",
                    eventDate: Date().addingTimeInterval(-86400), // Yesterday
                    status: .expired,
                    price: 19.99,
                    purchaseDate: Date().addingTimeInterval(-172800), // 2 days ago
                    expirationDate: Date().addingTimeInterval(-3600), // 1 hour ago
                    qrCode: "QR456789123"
                )
            ]
            self.isLoading = false
        }
    }
    
    func purchasePass(for venue: Venue) {
        isLoading = true
        error = nil
        
        // Simulate network delay and payment processing
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            // Simulate a 10% chance of payment failure
            let randomValue = Int.random(in: 1...10)
            if randomValue == 1 {
                self.error = NSError(domain: "PaymentError", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Payment processing failed. Please try again."])
                self.isLoading = false
                return
            }
            
            // Payment successful, add new pass
            let newPass = Pass(
                id: "pass\(self.passes.count + 1)",
                name: "Standard Pass - \(venue.name)",
                venueId: venue.id,
                eventDate: Date().addingTimeInterval(86400), // Tomorrow
                status: .active,
                price: 29.99,
                purchaseDate: Date(),
                expirationDate: Date().addingTimeInterval(172800), // 2 days from now
                qrCode: "QR\(Int.random(in: 100000...999999))"
            )
            
            self.passes.append(newPass)
            self.isLoading = false
        }
    }
    
    func cancelPass(passId: String) {
        isLoading = true
        error = nil
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let index = self.passes.firstIndex(where: { $0.id == passId }) {
                // In a real app, we would call an API to cancel the pass
                // For now, we'll just update our local copy
                let updatedPass = Pass(
                    id: self.passes[index].id,
                    name: self.passes[index].name,
                    venueId: self.passes[index].venueId,
                    eventDate: self.passes[index].eventDate,
                    status: .cancelled,
                    price: self.passes[index].price,
                    purchaseDate: self.passes[index].purchaseDate,
                    expirationDate: self.passes[index].expirationDate,
                    qrCode: self.passes[index].qrCode
                )
                
                self.passes[index] = updatedPass
            } else {
                self.error = NSError(domain: "PassError", code: 1002, userInfo: [NSLocalizedDescriptionKey: "Pass not found."])
            }
            
            self.isLoading = false
        }
    }
}

// MARK: - Preview Helper

extension PassesViewModel {
    static func preview() -> PassesViewModel {
        let viewModel = PassesViewModel()
        viewModel.passes = [
            Pass(
                id: "pass1",
                name: "Weekend Pass - The Rooftop Bar",
                venueId: "venue1",
                eventDate: Date().addingTimeInterval(86400), // Tomorrow
                status: .active,
                price: 29.99,
                purchaseDate: Date().addingTimeInterval(-3600), // 1 hour ago
                expirationDate: Date().addingTimeInterval(172800), // 2 days from now
                qrCode: "QR123456789"
            ),
            Pass(
                id: "pass2",
                name: "VIP Access - Club Neon",
                venueId: "venue2",
                eventDate: Date().addingTimeInterval(172800), // 2 days from now
                status: .pending,
                price: 49.99,
                purchaseDate: Date().addingTimeInterval(-1800), // 30 minutes ago
                expirationDate: Date().addingTimeInterval(259200), // 3 days from now
                qrCode: "QR987654321"
            )
        ]
        return viewModel
    }
} 