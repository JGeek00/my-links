import Foundation

@MainActor
@Observable
class TagsViewModel {
    static var shared = TagsViewModel()
    
    var state: Enums.LoadingState<TagsResponse_DataClass> = .loading
    
    init() {
        self.state = .loading
    }
    
    func loadData(setLoading: Bool = false, page: Int? = nil) async {
        if setLoading == true {
            self.state = .loading
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
        let result = await instance.tags.fetchTags(page: page)
        if result.successful == true {
            DispatchQueue.main.async {
                if let data = result.data?.data {
                    self.state = .success(data)
                }
                else {
                    self.state = .failure
                }
            }
        }
        else {
            if result.statusCode == 401 {
                ApiClientProvider.shared.destroy()
                return
            }
            DispatchQueue.main.async {
                self.state = .failure
            }
        }
    }
    
    func loadNextPage() {
        Task {
            await loadData(page: self.state.data?.nextCursor)
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
        self.state = .loading
    }
}
