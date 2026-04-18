import SwiftUI

@MainActor
@Observable
class ElementsViewModel {
    @ObservationIgnored private let navigationRepository: NavigationRepository
    
    init(navigationRepository: NavigationRepository = RepositoriesContainer.shared.navigationRepository) {
        self.navigationRepository = navigationRepository
    }
    
    var catalogSelectedView: Enums.ElementsDetailView? {
        get { navigationRepository.catalogSelectedView }
        set { navigationRepository.catalogSelectedView = newValue }
    }
}
