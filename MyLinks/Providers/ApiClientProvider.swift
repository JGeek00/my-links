import Foundation

@MainActor
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
            DashboardViewModel.shared.reset()
            TagsProvider.shared.reset()
            CollectionsProvider.shared.reset()
            LinksViewModel.shared.reset()
            ApiClientProvider.shared.instance = nil
            clearInstances()
        }
    }
}
