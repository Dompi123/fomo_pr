import Foundation

public struct CoreVersion {
    public static let version = "1.0.0"
    
    public static func getVersionInfo() -> String {
        return "Core Framework Version \(version)"
    }
}

public protocol CoreService {
    var serviceIdentifier: String { get }
    func initialize()
}

public class NetworkService: CoreService {
    public let serviceIdentifier = "com.fomopr.network"
    
    public init() {}
    
    public func initialize() {
        print("NetworkService initialized")
    }
    
    public func request(url: URL, method: String = "GET", headers: [String: String]? = nil) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
}

public class StorageService: CoreService {
    public let serviceIdentifier = "com.fomopr.storage"
    
    public init() {}
    
    public func initialize() {
        print("StorageService initialized")
    }
    
    public func saveData(_ data: Data, forKey key: String) {
        UserDefaults.standard.set(data, forKey: key)
    }
    
    public func loadData(forKey key: String) -> Data? {
        return UserDefaults.standard.data(forKey: key)
    }
}
