import Foundation

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var contactDeveloperSafariOpen = false
    @Published var dataSourceSafariOpen = false
    @Published var showBuildNumber = false
    @Published var linkwardenSiteOpen = false
    @Published var linkwardenRepoOpen = false
}
