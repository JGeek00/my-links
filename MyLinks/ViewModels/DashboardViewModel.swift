import Foundation
import SwiftUI

class DashboardViewModel: ObservableObject { 
    static let shared = DashboardViewModel()
    
    @Published var data: [Link] = []
    @Published var loading = true
    @Published var error = false
    
    @Published var path = NavigationPath()
    
    func loadData(setLoading: Bool = false) async {
        if setLoading == true {
            DispatchQueue.main.sync {
                self.loading = true
                self.data = []
            }
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let result = await instance.fetchDashboard()
        if result.successful == true {
            DispatchQueue.main.async {
                self.data = result.data?.response ?? []
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.loading = false
                    self.error = false
                }
            }
        }
        else {
            if result.statusCode == 401 {
                ApiClientProvider.shared.destroy()
                return
            }
            DispatchQueue.main.async {
                self.loading = false
                self.error = true
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
    
    func reloadAll(setLoading: Bool = false) async {
        await loadData(setLoading: setLoading)
        _ = await (LinksViewModel.shared.loadData(), LinksViewModel.shared.scrollTopList.toggle(), CollectionsProvider.shared.loadData(), TagsProvider.shared.loadData())
    }
}
