import Foundation

class SettingsViewModel: ObservableObject {
    @Published var contactDeveloperSafariOpen = false
    @Published var dataSourceSafariOpen = false
    @Published var showBuildNumber = false
    @Published var linkwardenSiteOpen = false
    @Published var linkwardenRepoOpen = false
    
    func disconnectServer() {
        OnboardingViewModel.shared.showOnboarding = true
        ApiClientProvider.shared.instance = nil
        clearInstances()
        TagsProvider.shared.reset()
        CollectionsProvider.shared.reset()
    }
}
