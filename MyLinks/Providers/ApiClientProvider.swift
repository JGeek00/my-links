import Foundation

class ApiClientProvider: ObservableObject {
    static let shared = ApiClientProvider()
    
    @Published var instance: ApiClient? = nil
    
    init() {}
    
    func initialice(instance: ApiClient) {
        self.instance = instance
    }
    
    func destroy(sessionExpired: Bool? = nil) {
        DispatchQueue.main.async {
            OnboardingViewModel.shared.showOnboarding = true
            ApiClientProvider.shared.instance = nil
            clearInstances()
            TagsProvider.shared = TagsProvider()
            CollectionsProvider.shared = CollectionsProvider()
            LinksViewModel.shared = LinksViewModel()
        }
    }
}
