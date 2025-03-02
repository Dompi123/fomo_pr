import Foundation
import SwiftUI

// MARK: - Base View Model
public class BaseViewModel: ObservableObject {
    @Published public var isLoading = false
    @Published public var error: Error?
    
    public init() {}
    
    public func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    public func setError(_ error: Error?) {
        self.error = error
    }
} 