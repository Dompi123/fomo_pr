import SwiftUI

struct TypesTestEntry: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: TypesTestView()) {
                    Text("Test Types Availability")
                }
            }
        }
    }
}

#Preview {
    TypesTestEntry()
}
