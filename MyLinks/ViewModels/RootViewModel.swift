import SwiftUI
import AlertToast

@MainActor
@Observable
class RootViewModel {
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    @ObservationIgnored private let toastRepository: ToastRepository
    @ObservationIgnored private let collectionsRepository: CollectionsRepository
    @ObservationIgnored private let navigationRepository: NavigationRepository
    @ObservationIgnored private let progressIndicatorRepository: ProgressIndicatorRepository
    
    init(apiClientRepository: ApiClientRepository = RepositoriesContainer.shared.apiClientRepository, toastRepository: ToastRepository = RepositoriesContainer.shared.toastRepository, collectionsRepository: CollectionsRepository = RepositoriesContainer.shared.collectionsRepository, navigationRepository: NavigationRepository = RepositoriesContainer.shared.navigationRepository, progressIndicatorRepository: ProgressIndicatorRepository = RepositoriesContainer.shared.progressIndicatorRepository) {
        self.apiClientRepository = apiClientRepository
        self.toastRepository = toastRepository
        self.collectionsRepository = collectionsRepository
        self.navigationRepository = navigationRepository
        self.progressIndicatorRepository = progressIndicatorRepository
    }
    
    var showOnboarding = false
    
    func initApiClientInstance() {
        apiClientRepository.loadInstance {
            self.showOnboarding = true
        }
    }
    
    func fetchCollections() {
        Task {
            await collectionsRepository.loadData()
        }
    }
    
    var toastPresenting: Bool {
        get { toastRepository.presenting }
        set { toastRepository.presenting = newValue }
    }
    
    var toast: AlertToast? {
        return toastRepository.toast
    }
    
    var apiClientInstance: ApiClient? {
        return apiClientRepository.instance
    }
    
    var selectedNavigationTab: Enums.TabViewTabs {
        get { navigationRepository.selectedNavigationTab }
        set { navigationRepository.selectedNavigationTab = newValue }
    }
    
    var showingProgressIndicator: Bool {
        get { progressIndicatorRepository.presenting }
        set { progressIndicatorRepository.presenting = newValue }
    }

}
