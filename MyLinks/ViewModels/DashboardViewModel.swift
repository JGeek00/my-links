import Foundation

class DashboardViewModel: ObservableObject { 
    static let shared = DashboardViewModel()
    
    @Published var data: [Link] = []
    @Published var loading = true
    @Published var error = false
    
    func loadData(setLoading: Bool = false) async {
        if setLoading == true {
            DispatchQueue.main.sync {
                self.loading = true
            }
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let dashboardResult = await instance.fetchDashboard()
        if dashboardResult.successful == true {
            DispatchQueue.main.async {
                self.data = dashboardResult.data?.response ?? []
                self.loading = false
                self.error = false
            }
        }
        else {
            if dashboardResult.statusCode == 401 {
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
    
    func reloadAll() async {
        _ = await (loadData(setLoading: true), LinksViewModel.shared.loadData(), LinksViewModel.shared.scrollTopList.toggle(), CollectionsProvider.shared.loadData(), TagsProvider.shared.loadData())
    }
}
