import Foundation
import SwiftUI
import Core

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