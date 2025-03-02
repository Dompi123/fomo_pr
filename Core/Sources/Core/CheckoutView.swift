import Foundation
import SwiftUI
import Models

// MARK: - CheckoutView
public struct CheckoutView: View {
    private let order: DrinkOrder
    @Environment(\.presentationMode) private var presentationMode
    @State private var isProcessing = false
    @State private var isComplete = false
    
    public init(order: DrinkOrder) {
        self.order = order
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: FOMOTheme.Spacing.large) {
                if isComplete {
                    VStack(spacing: FOMOTheme.Spacing.medium) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 72))
                            .foregroundColor(FOMOTheme.Colors.success)
                        
                        Text("Order Complete!")
                            .font(FOMOTheme.Typography.title2)
                        
                        Text("Your drinks will be ready shortly.")
                            .font(FOMOTheme.Typography.body)
                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(FOMOTheme.Colors.primary)
                        .foregroundColor(.white)
                        .cornerRadius(FOMOTheme.Radius.medium)
                        .padding(.top, FOMOTheme.Spacing.large)
                    }
                    .padding()
                } else {
                    List {
                        Section(header: Text("Order Items")) {
                            ForEach(order.items) { item in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.drink.name)
                                            .font(FOMOTheme.Typography.body)
                                        Text("\(item.quantity) x $\(String(format: "%.2f", item.drink.price))")
                                            .font(FOMOTheme.Typography.caption1)
                                            .foregroundColor(FOMOTheme.Colors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("$\(String(format: "%.2f", item.totalPrice))")
                                        .font(FOMOTheme.Typography.body)
                                }
                            }
                        }
                        
                        Section {
                            HStack {
                                Text("Total")
                                    .font(FOMOTheme.Typography.headline)
                                
                                Spacer()
                                
                                Text("$\(String(format: "%.2f", order.totalPrice))")
                                    .font(FOMOTheme.Typography.headline)
                                    .foregroundColor(FOMOTheme.Colors.primary)
                            }
                        }
                    }
                    #if os(iOS)
                    .listStyle(InsetGroupedListStyle())
                    #else
                    .listStyle(DefaultListStyle())
                    #endif
                    
                    Button(action: processOrder) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Place Order")
                                .font(FOMOTheme.Typography.headline)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(FOMOTheme.Colors.primary)
                    .foregroundColor(.white)
                    .cornerRadius(FOMOTheme.Radius.medium)
                    .padding(.horizontal)
                    .disabled(isProcessing)
                }
            }
            .navigationTitle("Checkout")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        }
    }
    
    private func processOrder() {
        isProcessing = true
        
        // Simulate processing delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isProcessing = false
            isComplete = true
        }
    }
} 