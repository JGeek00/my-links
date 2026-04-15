import Foundation

@MainActor
@Observable
class SettingsViewModel {
    var contactDeveloperSafariOpen = false
    var dataSourceSafariOpen = false
    var showBuildNumber = false
    var linkwardenSiteOpen = false
    var linkwardenRepoOpen = false
    var appInfoWebOpen = false
    var myOtherAppsOpen = false
}
