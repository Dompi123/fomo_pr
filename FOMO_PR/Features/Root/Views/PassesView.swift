import SwiftUI
import FOMO_PR  // Import for FOMOTheme (includes FOMOThemeExtensions)
// FOMOThemeExtensions is now part of FOMO_PR module - no separate import needed

struct PassesView: View {
    var body: some View {
        VStack {
            Image(systemName: "ticket")
                .passesIconStyle()
            
            Text("My Passes")
                .passesHeadingStyle()
                .padding(.bottom, FOMOTheme.Spacing.xxSmall)
            
            Text("You don't have any passes yet")
                .passesSubheadingStyle()
                .padding(.bottom, FOMOTheme.Spacing.medium)
            
            Button(action: {
                // Action to browse venues
            }) {
                Text("Browse Venues")
                    .fontWeight(.semibold)
                    .fomoPrimaryButtonStyle()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fomoBackground()
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