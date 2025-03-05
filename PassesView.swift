import SwiftUI

struct PassesView: View {
    var body: some View {
        VStack {
            Image(systemName: "ticket")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding()
            
            Text("My Passes")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 4)
            
            Text("You don't have any passes yet")
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            Button(action: {
                // Action to browse venues
            }) {
                Text("Browse Venues")
                    .fontWeight(.semibold)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
        .navigationTitle("My Passes")
    }
}

#if DEBUG
struct PassesView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PassesView()
        }
    }
}
#endif 