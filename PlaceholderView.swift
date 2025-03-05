import SwiftUI

struct PlaceholderView: View {
    var body: some View {
        VStack {
            Image(systemName: "building.2")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .padding()
            
            Text("Coming Soon")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 4)
            
            Text("This feature is under development")
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#if DEBUG
struct PlaceholderView_Previews: PreviewProvider {
    static var previews: some View {
        PlaceholderView()
    }
}
#endif 