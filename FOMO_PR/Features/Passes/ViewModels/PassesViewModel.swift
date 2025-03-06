import Foundation
import SwiftUI
import FOMO_PR

// Define Pass model since Models module doesn't exist
struct Pass: Identifiable, Decodable {
    let id: String
    let name: String
    let venueId: String
    let eventDate: Date
    let status: PassStatus
    
    enum PassStatus: String, Decodable {
        case active
        case expired
        case used
    }
    
    // Preview helper
    static var preview: Pass {
        Pass(
            id: "pass-123",
            name: "VIP Access",
            venueId: "venue-456",
            eventDate: Date(),
            status: .active
        )
    }
}

final class PassesViewModel: ObservableObject {
    @Published private(set) var passes: [Pass] = []
    @Published var isLoading: Bool = false
    
    private let apiClient = APIClient.shared
    
    init() {
        loadPasses()
    }
    
    func loadPasses() {
        isLoading = true
        
        Task {
            do {
                // Simulate network delay
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
                // Mock data
                let mockPasses = [
                    Pass(
                        id: "pass-123",
                        name: "VIP Access",
                        venueId: "venue-456",
                        eventDate: Date(),
                        status: .active
                    ),
                    Pass(
                        id: "pass-124",
                        name: "General Admission",
                        venueId: "venue-789",
                        eventDate: Date().addingTimeInterval(86400),
                        status: .active
                    ),
                    Pass(
                        id: "pass-125",
                        name: "Weekend Pass",
                        venueId: "venue-456",
                        eventDate: Date().addingTimeInterval(-86400),
                        status: .expired
                    )
                ]
                
                await MainActor.run {
                    self.passes = mockPasses
                    self.isLoading = false
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    func pass(withId id: String) -> Pass? {
        passes.first { $0.id == id }
    }
    
    func passes(forVenueId venueId: String) -> [Pass] {
        passes.filter { $0.venueId == venueId }
    }
    
    // MARK: - Computed Properties
    
    var activePasses: [Pass] {
        passes.filter { $0.status == .active }
    }
    
    var expiredPasses: [Pass] {
        passes.filter { $0.status == .expired }
    }
    
    var usedPasses: [Pass] {
        passes.filter { $0.status == .used }
    }
}

// MARK: - Preview
extension PassesViewModel {
    static var preview: PassesViewModel {
        let viewModel = PassesViewModel()
        return viewModel
    }
} 