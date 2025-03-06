import Foundation

// MARK: - Task Synchronous Extensions
// This extension allows us to call async functions from synchronous contexts

extension Task where Failure == Error {
    /// Executes an async throwing operation synchronously, blocking the current thread until completion
    /// - Parameter operation: The async operation to perform
    /// - Returns: The result of the operation
    /// - Throws: Any error thrown by the operation
    static func sync<T>(operation: @escaping () async throws -> T) throws -> T {
        let semaphore = DispatchSemaphore(value: 0)
        var result: Result<T, Error>?
        
        Task {
            do {
                let value = try await operation()
                result = .success(value)
            } catch {
                result = .failure(error)
            }
            semaphore.signal()
        }
        
        // Wait for the task to complete
        semaphore.wait()
        
        // Unwrap and return the result or throw the error
        guard let unwrappedResult = result else {
            throw NSError(domain: "TaskSyncError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Task sync operation failed with no result"])
        }
        
        return try unwrappedResult.get()
    }
} 