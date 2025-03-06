import SwiftUI

struct PricingCard: View {
    let tier: PricingTier
    let isSelected: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(tier.name)
                .font(.headline)
                .foregroundColor(isSelected ? .blue : .primary)
            
            Text("$\(String(format: "%.2f", tier.price))")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(isSelected ? .blue : .primary)
            
            Text(tier.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            // Features
            VStack(alignment: .leading, spacing: 8) {
                Text("Features:").font(.subheadline).fontWeight(.medium)
                
                ForEach(PricingTier.features(for: tier), id: \.self) { feature in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 14))
                        
                        Text(feature)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.vertical, 8)
            
            Spacer()
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: isSelected ? .blue.opacity(0.3) : .gray.opacity(0.2), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
} 