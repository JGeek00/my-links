import Foundation

class ApiClientProvider: ObservableObject {
    static let shared = ApiClientProvider()
    
    @Published var instance: ApiClient? = nil
    
    init() {}
    
    func initialice(instance: ApiClient) {
        self.instance = instance
    }
}
