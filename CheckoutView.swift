import SwiftUI
import OSLog

private let logger = Logger(subsystem: "com.fomo.pr", category: "CheckoutView")

struct CheckoutView: View {
    @EnvironmentObject private var navigationCoordinator: PreviewNavigationCoordinator
    @StateObject private var viewModel: CheckoutViewModel
    
    init(order: DrinkOrder) {
        _viewModel = StateObject(wrappedValue: CheckoutViewModel(order: order))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Processing payment...")
                        .padding()
                } else if viewModel.isPaymentComplete {
                    paymentSuccessView
                } else {
                    checkoutFormView
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    navigationCoordinator.dismissSheet()
                }
            )
            .alert(item: $viewModel.errorMessage) { error in
                Alert(
                    title: Text("Payment Error"),
                    message: Text(error.message),
                    dismissButton: .default(Text("OK"))
                )
            }
            .onAppear {
                logger.debug("CheckoutView appeared with order: \(viewModel.order.id)")
            }
        }
    }
    
    private var checkoutFormView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Order summary
                orderSummarySection
                
                // Payment method
                paymentMethodSection
                
                // Billing information
                billingInfoSection
                
                // Payment button
                Button(action: {
                    Task {
                        await viewModel.processPayment()
                    }
                }) {
                    Text("Pay \(viewModel.order.total.formatted(.currency(code: "USD")))")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.isFormValid ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!viewModel.isFormValid)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    private var orderSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Order Summary")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                ForEach(viewModel.order.items) { item in
                    HStack {
                        Text(item.name)
                        
                        Spacer()
                        
                        Text("\(item.quantity)x")
                            .foregroundColor(.secondary)
                        
                        Text(item.formattedPrice)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    
                    if item.id != viewModel.order.items.last?.id {
                        Divider()
                            .padding(.leading)
                    }
                }
                
                Divider()
                    .padding(.leading)
                
                HStack {
                    Text("Total")
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(viewModel.order.total.formatted(.currency(code: "USD")))
                        .font(.headline)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
            }
            .cornerRadius(12)
            .padding(.horizontal)
        }
    }
    
    private var paymentMethodSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Payment Method")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach(viewModel.paymentMethods, id: \.id) { method in
                    HStack {
                        Image(systemName: method.iconName)
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        
                        Text(method.name)
                        
                        Spacer()
                        
                        if viewModel.selectedPaymentMethod?.id == method.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                    .onTapGesture {
                        viewModel.selectedPaymentMethod = method
                    }
                }
                
                Button(action: {
                    viewModel.isAddingNewPaymentMethod = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add Payment Method")
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var billingInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Billing Information")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                TextField("Name on Card", text: $viewModel.nameOnCard)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                TextField("Billing Address", text: $viewModel.billingAddress)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                TextField("City", text: $viewModel.city)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(8)
                
                HStack(spacing: 12) {
                    TextField("State", text: $viewModel.state)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                    
                    TextField("Zip Code", text: $viewModel.zipCode)
                        .keyboardType(.numberPad)
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var paymentSuccessView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .padding()
            
            Text("Payment Successful!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Your order has been processed successfully.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Text("Order #\(viewModel.orderConfirmationNumber)")
                .font(.headline)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
            
            Button(action: {
                navigationCoordinator.dismissSheet()
            }) {
                Text("Done")
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

class CheckoutViewModel: ObservableObject {
    @Published var order: DrinkOrder
    @Published var selectedPaymentMethod: PaymentMethod?
    @Published var nameOnCard: String = ""
    @Published var billingAddress: String = ""
    @Published var city: String = ""
    @Published var state: String = ""
    @Published var zipCode: String = ""
    @Published var isLoading: Bool = false
    @Published var isPaymentComplete: Bool = false
    @Published var errorMessage: ErrorMessage?
    @Published var isAddingNewPaymentMethod: Bool = false
    @Published var orderConfirmationNumber: String = ""
    
    let paymentMethods: [PaymentMethod] = [
        PaymentMethod(id: "1", name: "Visa ending in 4242", iconName: "creditcard.fill"),
        PaymentMethod(id: "2", name: "Apple Pay", iconName: "apple.logo")
    ]
    
    var isFormValid: Bool {
        selectedPaymentMethod != nil &&
        !nameOnCard.isEmpty &&
        !billingAddress.isEmpty &&
        !city.isEmpty &&
        !state.isEmpty &&
        !zipCode.isEmpty
    }
    
    init(order: DrinkOrder) {
        self.order = order
        self.selectedPaymentMethod = paymentMethods.first
    }
    
    func processPayment() async {
        guard isFormValid else {
            errorMessage = ErrorMessage(message: "Please fill in all required fields")
            return
        }
        
        await MainActor.run {
            isLoading = true
        }
        
        do {
            // Simulate network delay
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            // Generate a random confirmation number
            let confirmationNumber = String(format: "%08d", Int.random(in: 10000000...99999999))
            
            await MainActor.run {
                self.orderConfirmationNumber = confirmationNumber
                self.isLoading = false
                self.isPaymentComplete = true
            }
        } catch {
            await MainActor.run {
                self.errorMessage = ErrorMessage(message: "Payment processing failed: \(error.localizedDescription)")
                self.isLoading = false
            }
        }
    }
}

struct PaymentMethod: Identifiable {
    let id: String
    let name: String
    let iconName: String
}

struct ErrorMessage: Identifiable {
    let id = UUID()
    let message: String
}

#if DEBUG
struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(order: DrinkOrder(
            items: [
                DrinkItem(name: "Mojito", price: 12.99, quantity: 2),
                DrinkItem(name: "Margarita", price: 10.99, quantity: 1)
            ]
        ))
        .environmentObject(PreviewNavigationCoordinator.shared)
        .preferredColorScheme(.dark)
    }
}
#endif 