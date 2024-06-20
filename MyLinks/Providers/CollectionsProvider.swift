import Foundation

class CollectionsProvider: ObservableObject {
    static let shared = CollectionsProvider()
    
    @Published var data: [Collection] = []
    @Published var loading = true
    @Published var error = false
    
    @Published var deleting = false
    @Published var deleteError = false
    
    init() {}
    
    func loadData(setLoading: Bool = false) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let collectionsResult = await instance.fetchCollections()
        if collectionsResult.successful == true {
            DispatchQueue.main.async {
                self.data = collectionsResult.data?.response ?? []
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
    
    func deleteCollection(id: Int) {
        guard let instance = ApiClientProvider.shared.instance else { return }
        self.deleting = true
        Task {
            let result = await instance.deleteCollection(collectionId: id)
            if result.successful == true {
                DispatchQueue.main.async {
                    self.deleting = false
                    self.deleteError = false
                    Task { await self.loadData() }
                    if !LinksViewModel.shared.data.isEmpty {
                        Task { await LinksViewModel.shared.loadData() }
                    }
                    if !DashboardViewModel.shared.data.isEmpty {
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
    
    func reset() {
        data = []
        loading = true
        error = false
        deleting = false
        deleteError = false
    }
}
