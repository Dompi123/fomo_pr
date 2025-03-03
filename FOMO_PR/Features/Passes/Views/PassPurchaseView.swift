import SwiftUI
import Models
import Core

struct PassPurchaseView: View {
    let venue: Venue
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: PassesViewModel = PassesViewModel()
    @State private var isProcessing = false
    @State private var error: Error?
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Venue Info
                VStack(alignment: .leading, spacing: 8) {
                    Text(venue.name)
                        .font(.title)
                        .bold()
                    
                    Text(venue.description)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Pass Options
                ScrollView {
                    VStack(spacing: 16) {
                        PassOptionCard(
                            title: "Standard Pass",
                            price: 25.0,
                            description: "Basic venue access",
                            isSelected: true
                        )
                        
                        PassOptionCard(
                            title: "VIP Pass",
                            price: 50.0,
                            description: "Priority entry and exclusive benefits",
                            isSelected: false
                        )
                        
                        PassOptionCard(
                            title: "Premium Pass",
                            price: 75.0,
                            description: "All VIP benefits plus complimentary drinks",
                            isSelected: false
                        )
                    }
                    .padding()
                }
                
                // Purchase Button
                Button(action: {
                    Task {
                        await purchasePass()
                    }
                }) {
                    if isProcessing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        Text("Purchase Pass")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .disabled(isProcessing)
                .padding()
            }
            .navigationTitle("Purchase Pass")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(error != nil)) {
                Button("OK") {
                    error = nil
                }
            } message: {
                if let error = error {
                    Text(error.localizedDescription)
                }
            }
        }
    }
    
    private func purchasePass() async {
        isProcessing = true
        defer { isProcessing = false }
        
        do {
            // In a real app, this would make an API call
            try await Task.sleep(nanoseconds: 2_000_000_000) // Simulate network request
            dismiss()
        } catch {
            self.error = error
        }
    }
}

struct PassOptionCard: View {
    let title: String
    let price: Double
    let description: String
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                Spacer()
                Text("$\(price, specifier: "%.2f")")
                    .font(.title3)
                    .bold()
            }
            
            Text(description)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemBackground))
                .shadow(radius: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

#if DEBUG
struct PassPurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        PassPurchaseView(venue: .preview)
    }
}
#endif 