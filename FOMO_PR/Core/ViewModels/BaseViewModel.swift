import Foundation
import SwiftUI
import OSLog

open class BaseViewModel: ObservableObject {
    @Published public private(set) var isLoading = false
    @Published public var error: Error?
    
    private let logger = Logger(subsystem: "com.fomo.pr", category: "BaseViewModel")
    
    public init() {}
    
    public func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    public func handleError(_ error: Error) {
        self.error = error
        self.logger.error("\(error.localizedDescription)")
    }
    
    public func clearError() {
        DispatchQueue.main.async {
            self.error = nil
        }
    }
}

// MARK: - Loading View
public struct LoadingView: View {
    public var body: some View {
        FOMOAnimations.LoadingView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(FOMOTheme.Colors.background.opacity(0.8))
    }
}

// MARK: - Error View
public struct ErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    public init(error: Error, retryAction: @escaping () -> Void) {
        self.error = error
        self.retryAction = retryAction
    }
    
    public var body: some View {
        VStack(spacing: FOMOTheme.Spacing.medium) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(FOMOTheme.Colors.error)
            
            Text("Error")
                .font(FOMOTheme.Typography.title2)
                .foregroundColor(FOMOTheme.Colors.text)
            
            Text(error.localizedDescription)
                .font(FOMOTheme.Typography.body)
                .foregroundColor(FOMOTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: retryAction) {
                Text("Retry")
                    .font(FOMOTheme.Typography.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, FOMOTheme.Spacing.large)
                    .padding(.vertical, FOMOTheme.Spacing.small)
                    .background(FOMOTheme.Colors.primary)
                    .cornerRadius(FOMOTheme.Radius.medium)
            }
            .padding(.top)
        }
        .padding()
        .background(FOMOTheme.Colors.surface)
        .cornerRadius(FOMOTheme.Radius.large)
        .shadow(color: FOMOTheme.Shadow.medium, radius: 8, x: 0, y: 4)
        .padding()
    }
}

// MARK: - View Extensions
public extension View {
    func withLoadingOverlay(_ isLoading: Bool) -> some View {
        ZStack {
            self
            if isLoading {
                LoadingView()
            }
        }
    }
    
    func withErrorHandling(_ error: Error?, retryAction: @escaping () -> Void) -> some View {
        ZStack {
            self
            if let error = error {
                ErrorView(error: error, retryAction: retryAction)
            }
        }
    }
} 