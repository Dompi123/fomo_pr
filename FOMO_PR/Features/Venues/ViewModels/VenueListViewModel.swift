import Foundation
import SwiftUI

// Define necessary types
class BaseViewModel {
    @Published var isLoading = false
    @Published var error: Error?
    
    func setLoading(_ loading: Bool) {
        isLoading = loading
    }
    
    func handleError(_ error: Error) {
        self.error = error
    }
}

struct Venue: Identifiable {
    let id: String
    let name: String
    let description: String
    let location: String
    let imageURL: URL?
    
    static var preview: Venue {
        Venue(id: "venue-123", name: "Sample Venue", description: "A sample venue", location: "123 Main St", imageURL: nil)
    }
}

class APIClient {
    static let shared = APIClient()
    
    enum Endpoint {
        case getVenues
        case searchVenues(query: String)
    }
    
    func request<T>(_ endpoint: Endpoint) async throws -> T {
        // This is a stub implementation
        if T.self == [Venue].self {
            return [Venue.preview] as! T
        }
        
        throw NSError(domain: "APIClient", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not implemented"])
    }
}

final class VenueListViewModel: BaseViewModel {
    @Published private(set) var venues: [Venue] = []
    private let apiClient: APIClient
    
    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
        super.init()
        Task {
            await loadVenues()
        }
    }
    
    @MainActor
    func loadVenues() async {
        setLoading(true)
        defer { setLoading(false) }
        
        do {
            venues = try await apiClient.request(.getVenues) as [Venue]
        } catch {
            handleError(error)
        }
    }
    
    func filterVenues(by searchText: String) {
        Task {
            setLoading(true)
            defer { setLoading(false) }
            
            do {
                venues = try await apiClient.request(.searchVenues(query: searchText)) as [Venue]
            } catch {
                handleError(error)
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
extension VenueListViewModel {
    static var preview: VenueListViewModel {
        let viewModel = VenueListViewModel()
        viewModel.venues = [.preview]
        return viewModel
    }
} 