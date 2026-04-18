import Foundation
import SwiftUI

@MainActor
@Observable
class DashboardViewModel {
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    @ObservationIgnored private let collectionsRepository: CollectionsRepository
    @ObservationIgnored private let navigationRepository: NavigationRepository
    
    init() {
        self.apiClientRepository = RepositoriesContainer.shared.apiClientRepository
        self.collectionsRepository = RepositoriesContainer.shared.collectionsRepository
        self.navigationRepository = RepositoriesContainer.shared.navigationRepository
    }
    
    var state: Enums.LoadingState<DashboardResponse_Data> = .loading
    var collections: [Collection] = []
    var loadingCollections: Bool = true
    var errorCollections: Bool = false
        
    var path = NavigationPath()
    
    func loadData(setLoading: Bool = false) async {
        if setLoading == true {
            self.state = .loading
        }
        guard let instance = apiClientRepository.instance else { return }
        let result = await instance.dashboard.fetchDashboard()
        if let data = result.data?.data {
            DispatchQueue.main.async {
                withAnimation {
                    self.state = .success(data)
                }
            }
        }
        else {
            withAnimation {
                self.state = .failure
            }
        }
    }
    
    func reload() {
        Task { await loadData() }
    }
    
    func navigateRecent() {
        let request = LinksFilteredRequest(name: String(localized: "Recent"), mode: .recent, id: nil)
        path.append(request)
    }
    
    func navigatePinned() {
        let request = LinksFilteredRequest(name: String(localized: "Pinned"), mode: .pinned, id: nil)
        path.append(request)
    }
    
    func navigateLinksCatalog() {
        navigationRepository.navigateLinksCatalog()
    }
    
    func navigateCollectionsCatalog() {
        navigationRepository.navigateCollectionsCatalog()
    }
    
    func navigateTagsCatalog() {
        navigationRepository.navigateTagsCatalog()
    }
    
    func reset() {
        self.state = .loading
        self.path = NavigationPath()
    }
}
