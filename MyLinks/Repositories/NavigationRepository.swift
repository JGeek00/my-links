import Foundation

@Observable
class NavigationRepository {
    var selectedNavigationTab: Enums.TabViewTabs = .home
    var catalogSelectedView: Enums.ElementsDetailView? = nil
    
    func navigateLinksCatalog() {
        selectedNavigationTab = .catalog
        catalogSelectedView = .links
    }
    
    func navigateCollectionsCatalog() {
        selectedNavigationTab = .catalog
        catalogSelectedView = .collections
    }
    
    func navigateTagsCatalog() {
        selectedNavigationTab = .catalog
        catalogSelectedView = .tags
    }
}
