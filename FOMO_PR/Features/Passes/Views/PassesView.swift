import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.fomo.pr", category: "PassesView")

struct PassesView: View {
    @StateObject private var viewModel = PassesViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if viewModel.isLoading {
                    ProgressView("Loading passes...")
                        .padding()
                } else if let errorMessage = viewModel.errorMessage {
                    VStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 50))
                            .foregroundColor(.yellow)
                        
                        Text("Error Loading Passes")
                            .font(.headline)
                        
                        Text(errorMessage)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                        
                        Button("Try Again") {
                            Task {
                                await viewModel.fetchPasses()
                            }
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                } else if viewModel.passes.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "ticket")
                            .font(.system(size: 70))
                            .foregroundColor(.gray)
                            .padding()
                        
                        Text("No Passes Yet")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Visit a venue and purchase a pass to access premium features")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        Button("Browse Venues") {
                            // In a real app, this would navigate to the venues tab
                            logger.debug("Browse Venues button tapped")
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                } else {
                    ForEach(viewModel.passes) { pass in
                        PassCard(pass: pass)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.fetchPasses()
        }
        .onAppear {
            logger.debug("PassesView appeared")
            Task {
                await viewModel.fetchPasses()
            }
        }
    }
}

struct PassCard: View {
    let pass: Pass
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with venue name and pass type
            HStack {
                Text(pass.venueName)
                    .font(.headline)
                
                Spacer()
                
                Text(pass.type.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(pass.type == .premium ? Color.yellow.opacity(0.2) : Color.blue.opacity(0.2))
                    .foregroundColor(pass.type == .premium ? .yellow : .blue)
                    .cornerRadius(4)
            }
            
            Divider()
            
            // Pass details
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Valid until", systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(pass.expirationDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Label("Status", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(pass.isActive ? "Active" : "Inactive")
                        .font(.subheadline)
                        .foregroundColor(pass.isActive ? .green : .red)
                }
            }
            
            // QR Code placeholder
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
                
                Image(systemName: "qrcode")
                    .font(.system(size: 100))
                    .foregroundColor(.gray)
            }
            .frame(height: 150)
            .padding(.vertical, 8)
            
            // Pass ID
            HStack {
                Text("Pass ID:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(pass.id.prefix(8).uppercased())
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    // In a real app, this would share the pass
                }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// Pass model
struct Pass: Identifiable {
    let id: String
    let venueName: String
    let type: PassType
    let purchaseDate: Date
    let expirationDate: Date
    let isActive: Bool
    
    enum PassType: String, Codable {
        case standard = "Standard"
        case premium = "Premium"
    }
}

class PassesViewModel: ObservableObject {
    @Published var passes: [Pass] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchPasses() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 1_000_000_000)
            
            // In a real app, this would be a network call
            // For now, use mock data
            let mockPasses = [
                Pass(
                    id: UUID().uuidString,
                    venueName: "The Rooftop Bar",
                    type: .premium,
                    purchaseDate: Date().addingTimeInterval(-86400 * 3), // 3 days ago
                    expirationDate: Date().addingTimeInterval(86400 * 27), // 27 days from now
                    isActive: true
                ),
                Pass(
                    id: UUID().uuidString,
                    venueName: "Underground Lounge",
                    type: .standard,
                    purchaseDate: Date().addingTimeInterval(-86400 * 10), // 10 days ago
                    expirationDate: Date().addingTimeInterval(86400 * 20), // 20 days from now
                    isActive: true
                )
            ]
            
            await MainActor.run {
                self.passes = mockPasses
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Failed to load passes: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}

#if DEBUG
struct PassesView_Previews: PreviewProvider {
    static var previews: some View {
        PassesView()
            .preferredColorScheme(.dark)
    }
}
#endif 