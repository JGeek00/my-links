import Foundation

@MainActor
@Observable
class SettingsViewModel {
    @ObservationIgnored private var apiClientRepository: ApiClientRepository
    
    init(apiClientRepository: ApiClientRepository = RepositoriesContainer.shared.apiClientRepository) {
        self.apiClientRepository = apiClientRepository
    }
    
    var contactDeveloperSafariOpen = false
    var dataSourceSafariOpen = false
    var showBuildNumber = false
    var linkwardenSiteOpen = false
    var linkwardenRepoOpen = false
    var appInfoWebOpen = false
    var myOtherAppsOpen = false
    
    var apiClientInstance: ApiClient? {
        apiClientRepository.instance
    }
    
    func destroyServer() {
        apiClientRepository.destroy()
    }
}
