import Foundation

@MainActor
class TagsProvider: ObservableObject {
    static var shared = TagsProvider()
    
    @Published var data: [Tag] = []
    @Published var loading = true
    @Published var error = false
    
    init() {
        self.data = []
        self.loading = true
        self.error = false
    }
    
    func loadData(setLoading: Bool = false) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let result = await instance.fetchTags()
        if result.successful == true {
            DispatchQueue.main.async {
                if result.data?.response != nil {
                    let filtered = result.data!.response!.filter() { $0.id != nil && $0.name != nil && $0.createdAt != nil }
                    self.data = filtered.sorted() { $0.name! < $1.name! }
                }
                else {
                    self.data = []
                }
                self.loading = false
                self.error = false
            }
        }
        else {
            if result.statusCode == 401 {
                ApiClientProvider.shared.destroy()
                return
            }
            DispatchQueue.main.async {
                self.loading = false
                self.error = true
            }
        }
    }
    
    func createTag(name: String) async -> Bool {
        guard let instance = ApiClientProvider.shared.instance else { return false }
        let body = TagCreationRequest()
        body.tags.append(TagCreationItem(label: name))
        let result = await instance.createTag(body)
        if result.successful == true {
            await loadData(setLoading: false)
            return true;
        }
        else {
            return false;
        }
    }
    
    func deleteTag(tagId: Int) async -> Bool {
        guard let instance = ApiClientProvider.shared.instance else { return false }
        let result = await instance.deleteTag(tagId: tagId)
        if result.successful == true {
            await loadData(setLoading: false)
            return true;
        }
        else {
            return false;
        }
    }
    
    func reset() {
        data = []
        loading = true
        error = false
    }
}
