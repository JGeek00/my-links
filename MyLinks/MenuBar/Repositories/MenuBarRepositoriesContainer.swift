import Foundation

@MainActor
class MenuBarRepositoriesContainer {
    static let shared = MenuBarRepositoriesContainer()
    
    let apiClientRepository = MenuBarApiClientRepository()
}
