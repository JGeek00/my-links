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
    
    init() {
        self.apiClientRepository = RepositoriesContainer.shared.apiClientRepository
        self.toastRepository = RepositoriesContainer.shared.toastRepository
        self.collectionsRepository = RepositoriesContainer.shared.collectionsRepository
        self.navigationRepository = RepositoriesContainer.shared.navigationRepository
        self.progressIndicatorRepository = RepositoriesContainer.shared.progressIndicatorRepository
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
