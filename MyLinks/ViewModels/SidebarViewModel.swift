import SwiftUI

@MainActor
@Observable
class SidebarViewModel {
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    @ObservationIgnored private let collectionsRepository: CollectionsRepository
    
    init(apiClientRepository: ApiClientRepository = RepositoriesContainer.shared.apiClientRepository, collectionsRepository: CollectionsRepository = RepositoriesContainer.shared.collectionsRepository) {
        self.apiClientRepository = apiClientRepository
        self.collectionsRepository = collectionsRepository
    }
    
    var collections: [Collection] {
        get { collectionsRepository.data }
    }
    
    var tags: [TagsResponse_DataClass_Tag] = []
    var loadingTags: Bool = true
    var errorTags: Bool = false
    
    var errorDeleteTagAlert = false
    
    func fetchTags() {
        guard let apiClient = apiClientRepository.instance else { return }
        Task {
            let result = await apiClient.tags.fetchTags()
            if let tags = result.data?.data?.tags {
                DispatchQueue.main.async {
                    self.tags = tags
                    self.loadingTags = false
                }
            }
            else {
                DispatchQueue.main.async {
                    self.loadingTags = false
                    self.errorTags = true
                }
            }
        }
    }
    
    func deleteTag(tagId: Int) {
        guard let apiClient = apiClientRepository.instance else { return }
        Task {
            let result = await apiClient.tags.deleteTag(tagId: tagId)
            if result.successful {
                fetchTags()
            }
            else {
                DispatchQueue.main.async {
                    self.errorDeleteTagAlert = true
                }
            }
        }
    }
}
