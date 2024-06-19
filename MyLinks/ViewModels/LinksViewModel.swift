import Foundation

class LinksViewModel: ObservableObject {
    static let shared = LinksViewModel()
    
    @Published var data: Links? = nil
    @Published var loading = true
    @Published var error = false
        
    @Published var deleting = false
    @Published var deleteError = false
    
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
    
    func deleteLink(id: Int) {
        guard let instance = ApiClientProvider.shared.instance else { return }
        self.deleting = true
        Task {
            let result = await instance.deleteLink(linkId: id)
            if result.successful == true {
                DispatchQueue.main.async {
                    self.deleting = false
                    self.deleteError = false
                    Task { await self.loadData() }
                    if DashboardViewModel.shared.data != nil {
                        Task { await DashboardViewModel.shared.loadData() }
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    self.deleting = false
                    self.deleteError = true
                }
            }
        }
    }
}
