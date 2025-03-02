import Foundation
import SwiftUI

open class BaseViewModel {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    public init() {}
    
    func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    func handleError(_ error: Error) {
        self.error = error
    }
} 