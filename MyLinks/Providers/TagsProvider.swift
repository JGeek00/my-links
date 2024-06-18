import Foundation

class TagsProvider: ObservableObject {
    static let shared = TagsProvider()
    
    @Published var data: Tags? = nil
    @Published var loading = true
    @Published var error = false
    
    init() {}
    
    func loadData(setLoading: Bool = false) {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        Task {
            let result = await instance.fetchTags()
            if result.successful == true {
                DispatchQueue.main.async {
                    self.data = result.data!
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
