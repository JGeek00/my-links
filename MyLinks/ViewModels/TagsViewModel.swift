import Foundation

@MainActor
@Observable
class TagsViewModel {
    static var shared = TagsViewModel()
    
    var data: [TagsResponse_DataClass_Tag] = []
    var loading = true
    var error = false
    
    @ObservationIgnored var nextPage: Int? = nil
    
    init() {
        self.data = []
        self.loading = true
        self.error = false
    }
    
    func loadData(setLoading: Bool = false, page: Int? = nil) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let result = await instance.tags.fetchTags(page: page)
        if result.successful == true {
            DispatchQueue.main.async {
                if let data = result.data?.data {
                    self.data = data.tags.sorted() { $0.name < $1.name }
                    self.nextPage = data.nextCursor
                }
                else {
                    self.data = []
                    self.nextPage = nil
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
    
    func loadNextPage() {
        Task {
            await loadData(page: self.nextPage)
        }
    }
    
    func createTag(name: String) async -> Bool {
        guard let instance = ApiClientProvider.shared.instance else { return false }
        let body = TagCreationRequest()
        body.tags.append(TagCreationItem(label: name))
        let result = await instance.tags.createTag(body)
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
        let result = await instance.tags.deleteTag(tagId: tagId)
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
