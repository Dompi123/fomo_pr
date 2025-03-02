import Foundation
import SwiftUI

@MainActor
open class BaseViewModel: ObservableObject {
    @Published public private(set) var isLoading = false
    @Published public private(set) var error: Error?
    
    public init() {}
    
    public func handleError(_ error: Error) {
        self.error = error
    }
    
    public func setLoading(_ loading: Bool) {
        isLoading = loading
    }
} 