import Foundation
import SwiftUI

@MainActor
@Observable
class DashboardViewModel {
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    @ObservationIgnored private let collectionsRepository: CollectionsRepository
    @ObservationIgnored private let navigationRepository: NavigationRepository
    @ObservationIgnored private let progressIndicatorRepository: ProgressIndicatorRepository
    @ObservationIgnored private let linkManagerRepository: LinkManagerRepository
    
    init() {
        self.apiClientRepository = RepositoriesContainer.shared.apiClientRepository
        self.collectionsRepository = RepositoriesContainer.shared.collectionsRepository
        self.navigationRepository = RepositoriesContainer.shared.navigationRepository
        self.progressIndicatorRepository = RepositoriesContainer.shared.progressIndicatorRepository
        self.linkManagerRepository = RepositoriesContainer.shared.linkManagerRepository
    }
    
    init(apiClientRepository: ApiClientRepository, collectionsRepository: CollectionsRepository, navigationRepository: NavigationRepository, progressIndicatorRepository: ProgressIndicatorRepository, linkManagerRepository: LinkManagerRepository) {
        self.apiClientRepository = apiClientRepository
        self.collectionsRepository = collectionsRepository
        self.navigationRepository = navigationRepository
        self.progressIndicatorRepository = progressIndicatorRepository
        self.linkManagerRepository = linkManagerRepository
    }
    
    var loading: Bool = true
    var error: Bool = false
    var data: DashboardResponse_Data? = nil
    var collections: [Collection] {
        get { collectionsRepository.data }
    }
    var loadingCollections: Bool {
        get { collectionsRepository.loading }
    }
    var errorCollections: Bool {
        get { collectionsRepository.error }
    }
    
    var deleteLinkErrorAlert: Bool = false
    var pinLinkErrorAlert: Bool = false
    var unpinLinkErrorAlert: Bool = false
        
    var path = NavigationPath()
    
    func loadData(setLoading: Bool = false) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = apiClientRepository.instance else { return }
        let result = await instance.dashboard.fetchDashboard()
        if let data = result.data?.data {
            DispatchQueue.main.async {
                withAnimation {
                    self.data = data
                    self.loading = false
                }
            }
        }
        else {
            withAnimation {
                self.error = true
                self.loading = false
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
    
    func handleAddLink(link: Link) {
        self.reload()
    }
    
    func handleDeleteLink(linkId: Int) {
        Task {
            await linkManagerRepository.deleteLink(id: linkId) { processing in
                DispatchQueue.main.async {
                    self.progressIndicatorRepository.presenting = processing
                }
            } onSuccess: { _ in
                self.reload()
            } onError: {
                DispatchQueue.main.async {
                    self.deleteLinkErrorAlert = true
                }
            }
        }
    }
    
    func handleEditLink(link: Link) {
        self.reload()
    }
    
    func handleAddCollection(collection: Collection) {
        Task { await self.collectionsRepository.loadData() }
    }
    
    func handlePinUnpin(link: Link, action: Enums.PinUnpinAction) {
        Task {
            await linkManagerRepository.pinUnpinLink(link: link, action: action) { processing in
                DispatchQueue.main.async {
                    self.progressIndicatorRepository.presenting = processing
                }
            } onSuccess: { _ in
                self.reload()
            } onError: {
                DispatchQueue.main.async {
                    switch action {
                    case .pin:
                        self.pinLinkErrorAlert = true
                    case .unpin:
                        self.unpinLinkErrorAlert = true
                    }
                }
            }
        }
    }
}
