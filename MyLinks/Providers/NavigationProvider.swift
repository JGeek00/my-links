import Foundation

class NavigationProvider: ObservableObject {
    @Published var selectedNavigationTab: Enums.TabViewTabs = .home
    @Published var catalogSelectedView: Enums.ElementsDetailView? = nil
    
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
