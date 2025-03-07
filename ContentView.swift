import SwiftUI
import OSLog

struct ContentView: View {
    var body: some View {
        ThemeShowcaseView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark)
    }
} 