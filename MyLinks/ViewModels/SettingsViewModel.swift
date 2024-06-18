import Foundation

class SettingsViewModel: ObservableObject {
    @Published var contactDeveloperSafariOpen = false
    @Published var dataSourceSafariOpen = false
    @Published var showBuildNumber = false
}
