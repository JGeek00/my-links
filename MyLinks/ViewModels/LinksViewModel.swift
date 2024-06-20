import Foundation

class LinksViewModel: ObservableObject {
    static let shared = LinksViewModel()
    
    @Published var data: Links? = nil
    @Published var loading = true
    @Published var error = false
    
    func loadData(setLoading: Bool = false) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let dashboardResult = await instance.fetchLinks()
        if dashboardResult.successful == true {
            DispatchQueue.main.async {
                self.data = dashboardResult.data!
                self.loading = false
                self.error = false
            }
        }
        else {
            DispatchQueue.main.async {
                self.loading = false
                self.error = true
            }
        }
    }
    
    func reload() {
        Task { await loadData() }
        Task { await DashboardViewModel.shared.loadData() }
    }
}
