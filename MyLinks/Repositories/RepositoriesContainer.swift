import Foundation

@MainActor
class RepositoriesContainer {
    @MainActor static let shared = RepositoriesContainer()
    
    let apiClientRepository = ApiClientRepository()
    
    lazy var collectionsRepository: CollectionsRepository = {
        return CollectionsRepository(apiClientRepository: apiClientRepository)
    }()
    
    lazy var linkManagerRepository: LinkManagerRepository = {
        return LinkManagerRepository(apiClientRepository: apiClientRepository)
    }()
    
    let navigationRepository = NavigationRepository()
    
    let toastRepository = ToastRepository()
    
    let progressIndicatorRepository = ProgressIndicatorRepository()
}
