import Foundation

class CollectionsProvider: ObservableObject {
    static let shared = CollectionsProvider()
    
    @Published var data: Collections? = nil
    @Published var loading = true
    @Published var error = false
    
    init() {}
    
    func loadData(setLoading: Bool = false) {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        Task {
            let collectionsResult = await instance.fetchCollections()
            if collectionsResult.successful == true {
                DispatchQueue.main.async {
                    self.data = collectionsResult.data!
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
    
    func reset() {
        data = nil
        loading = true
        error = false
    }
}
