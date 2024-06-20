import Foundation

class TagsProvider: ObservableObject {
    static let shared = TagsProvider()
    
    @Published var data: [Tag] = []
    @Published var loading = true
    @Published var error = false
    
    init() {}
    
    func loadData(setLoading: Bool = false) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let result = await instance.fetchTags()
        if result.successful == true {
            DispatchQueue.main.async {
                self.data = result.data?.response ?? []
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
    
    func reset() {
        data = []
        loading = true
        error = false
    }
}
