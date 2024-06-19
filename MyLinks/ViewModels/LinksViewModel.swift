import Foundation

class LinksViewModel: ObservableObject {
    @Published var data: Links? = nil
    @Published var loading = true
    @Published var error = false
        
    init() {
        loadData()
    }
    
    func loadData(setLoading: Bool = false) {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        Task {
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
    }
}
