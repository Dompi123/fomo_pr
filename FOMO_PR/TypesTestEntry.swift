import SwiftUI

struct TypesTestEntry: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: TypesTestView()) {
                    Text("Test Types Availability")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
                
                Text("Click the button above to test if all required types are available in your app.")
                    .multilineTextAlignment(.center)
                    .padding()
            }
            .navigationTitle("Types Test")
        }
    }
}

#Preview {
    TypesTestEntry()
}
