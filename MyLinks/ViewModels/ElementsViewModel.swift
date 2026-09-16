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

    var selectedLink: SelectedLinkOpen? = nil
    var preferredColumn: NavigationSplitViewColumn = .sidebar
    var path = NavigationPath()

    func restoreCatalogSelection() {
        if let selected = catalogSelectedView, path.isEmpty {
            path.append(selected)
        }
    }

    func navigateDetail(link: Link, mode: Enums.OpenLinkAction) {
        selectedLink = SelectedLinkOpen(link: link, type: mode, source: nil)
        preferredColumn = .detail
    }

    func isSelected(link: Link) -> Bool {
        guard let selectedLink = selectedLink else { return false }
        return selectedLink.link.id == link.id
    }
}
