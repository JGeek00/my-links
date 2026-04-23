import Foundation

@MainActor
class ShareExtensionRepositoriesContainer {
    static let shared = ShareExtensionRepositoriesContainer()
    
    let apiClientRepository = ShareExtensionApiClientRepository()
}
