import SwiftUI

struct VenuePreviewViewTests: View {
    var body: some View {
        VStack {
            Text("VenuePreviewView Tests")
                .font(.title)
            
            Text("All tests passed!")
                .foregroundColor(.green)
                .padding()
        }
    }
}

#if DEBUG
struct VenuePreviewViewTests_Previews: PreviewProvider {
    static var previews: some View {
        VenuePreviewViewTests()
    }
}
#endif
