import Foundation

class OnboardingViewModel: ObservableObject {
    @Published var selectedTab = 0
    @Published var hostingMode: Enums.Hosting? = nil
    
    @Published var token = ""
    @Published var connectionMethod = Enums.ConnectionMethod.http
    @Published var ipDomain = ""
    @Published var port = ""
    @Published var path = ""
}
