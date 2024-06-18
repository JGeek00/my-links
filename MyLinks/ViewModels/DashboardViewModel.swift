import Foundation

class DashboardViewModel: ObservableObject {
    @Published var dashboard: Dashboard? = nil
    @Published var collections: Collections? = nil
    @Published var tags: Tags? = nil
    @Published var loading = true
    @Published var error = false
    
    init() {}
    
    func loadData() {
        self.loading = true
        guard let instance = ApiClientProvider.shared.instance else { return }
        Task {
            let dashboardResult = await instance.fetchDashboard()
            let collectionsResult = await instance.fetchCollections()
            let tagsResult = await instance.fetchTags()
            if dashboardResult.successful == true && collectionsResult.successful == true && tagsResult.successful == true {
                DispatchQueue.main.async {
                    self.dashboard = dashboardResult.data!
                    self.tags = tagsResult.data!
                    self.collections = collectionsResult.data!
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
