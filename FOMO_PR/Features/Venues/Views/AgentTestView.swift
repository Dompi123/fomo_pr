import SwiftUI
import Foundation

struct AgentTestView: View {
    var body: some View {
        VStack {
            Text("Agent Test View")
                .font(.title)
            Text("Testing Agent Monitoring")
                .font(.title)
                .foregroundColor(.blue)
        }
    }
}

#if DEBUG
struct AgentTestView_Previews: PreviewProvider {
    static var previews: some View {
        AgentTestView()
    }
}
#endif
// Test change
