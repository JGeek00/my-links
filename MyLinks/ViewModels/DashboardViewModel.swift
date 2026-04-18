import Foundation
import SwiftUI

@MainActor
@Observable
class DashboardViewModel {
    static let shared = DashboardViewModel()
    
    var state: Enums.LoadingState<DashboardResponse_Data> = .loading
    
    var path = NavigationPath()
    
    init() {}
    
    func loadData(setLoading: Bool = false) async {
        if setLoading == true {
            self.state = .loading
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let result = await instance.dashboard.fetchDashboard()
        if let data = result.data?.data {
            DispatchQueue.main.async {
                withAnimation {
                    self.state = .success(data)
                }
            }
        }
        else {
            withAnimation {
                self.state = .failure
            }
        }
    }
    
    func reload() {
        Task { await loadData() }
        Task {
            await LinksViewModel.shared.loadData()
            LinksViewModel.shared.scrollTopList.toggle()
        }
    }
    
    func navigateRecent() {
        let request = LinksFilteredRequest(name: String(localized: "Recent"), mode: .recent, id: nil)
        path.append(request)
    }
    
    func navigatePinned() {
        let request = LinksFilteredRequest(name: String(localized: "Pinned"), mode: .pinned, id: nil)
        path.append(request)
    }
    
    func reset() {
        self.state = .loading
        self.path = NavigationPath()
    }
}
