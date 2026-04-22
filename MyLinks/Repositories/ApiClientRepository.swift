import Foundation

@MainActor
@Observable
class ApiClientRepository {
    var instance: ApiClient? = nil
    
    init() {}
    
    func initialice(instance: ApiClient) {
        self.instance = instance
    }
    
    func destroy(sessionExpired: Bool? = nil) {
        DispatchQueue.main.async {
            clearInstances()
            RepositoriesContainer.reset()
        }
    }
}
