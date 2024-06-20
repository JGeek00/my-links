import Foundation

class LinksFilteredViewModel: ObservableObject {
    @Published var input: LinksFilteredRequest
    
    init(input: LinksFilteredRequest) {
        self.input = input
    }
    
    @Published var data: Links? = nil
    @Published var loading = true
    @Published var error = false
    
    func loadData(setLoading: Bool = false) async {
        if (input.mode == .collection || input.mode == .pinned) && input.id == nil {
            return
        }
        
        if setLoading == true {
            self.loading = true
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let dashboardResult = await instance.fetchLinks(
            collectionId: input.mode == .collection ? input.id! : nil,
            tagId: input.mode == .tag ? input.id! : nil,
            pinnedOnly: input.mode == .pinned ? true : nil,
            recentOnly: input.mode == .recent ? true : nil
        )
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
        Task { await LinksViewModel.shared.loadData() }
    }
}
