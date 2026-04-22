import Foundation
import SwiftUI

@MainActor
@Observable
class SearchViewModel {
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    @ObservationIgnored private let linkManagerRepository: LinkManagerRepository
    @ObservationIgnored private let collectionsRepository: CollectionsRepository
    @ObservationIgnored private let progressIndicatorRepository: ProgressIndicatorRepository
  
    init() {
        self.apiClientRepository = RepositoriesContainer.shared.apiClientRepository
        self.linkManagerRepository = RepositoriesContainer.shared.linkManagerRepository
        self.collectionsRepository = RepositoriesContainer.shared.collectionsRepository
        self.progressIndicatorRepository = RepositoriesContainer.shared.progressIndicatorRepository
    }
    
    init(apiClientRepository: ApiClientRepository, linkManagerRepository: LinkManagerRepository, collectionsRepository: CollectionsRepository, progressIndicatorRepository: ProgressIndicatorRepository) {
        self.apiClientRepository = apiClientRepository
        self.linkManagerRepository = linkManagerRepository
        self.collectionsRepository = collectionsRepository
        self.progressIndicatorRepository = progressIndicatorRepository
    }
    
    var links: [Link] = []
    var tags: [TagsResponse_DataClass_Tag] = []
    var loading = false
    var error = false
    
    var allCollections: [Collection] {
        get { collectionsRepository.data }
        set { collectionsRepository.data = newValue }
    }
    var filteredCollections: [Collection] = []
    
    var searchFieldValue = ""
    var searchPresented = false
    var searchQueryValue: String? = nil
    var previousSearch: String? = nil
    
    var loadingMore = false
    
    var sortingSelected = Enums.SortingOptions.dateNewestFirst
    
    // Flag to triger onChange
    var scrollTopList = false
    
    var deleteLinkErrorAlert = false
    var deleteCollectionErrorAlert = false
    
    func loadData(
        setLoading: Bool = false,
        setError: Bool = true
    ) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = apiClientRepository.instance else { return }
        let (linksResult, tagsResult) = await (instance.links.fetchLinks(searchQueryString: searchQueryValue, searchByName: searchQueryValue != nil ? true : nil, sort: sortingSelected.rawValue), instance.tags.fetchTags(search: searchQueryValue))
        if let linksResult = linksResult.data?.response, let tagsResult = tagsResult.data?.data?.tags {
            DispatchQueue.main.async {
                self.links = linksResult
                self.tags = tagsResult
                self.filteredCollections = self.allCollections.filter({ $0.name.lowercased().contains((self.searchQueryValue?.lowercased()) ?? "") })
                withAnimation(.default) {
                    self.loading = false
                    self.error = false
                }
            }
        }
        else {
            if linksResult.statusCode == 401 || tagsResult.statusCode == 401 {
                apiClientRepository.destroy()
                return
            }
            DispatchQueue.main.async {
                withAnimation(.default) {
                    self.loading = false
                    if setError == true {
                        self.error = true
                    }
                }
            }
        }
    }
    
    func search() {
        self.searchQueryValue = searchFieldValue
        Task {
            await loadData(setLoading: true)
            self.previousSearch = searchFieldValue
        }
    }
    
    func clearSearch() {
        self.searchQueryValue = nil
        if previousSearch != nil {
            Task {
                await loadData(setLoading: true)
                self.previousSearch = nil
            }
        }
    }
    
    func handleDeleteLink(linkId: Int) {
        Task {
            await linkManagerRepository.deleteLink(id: linkId) { processing in
                self.progressIndicatorRepository.presenting = processing
            } onSuccess: { _ in
                self.links = self.links.filter() { $0.id != linkId }
            } onError: {
                self.deleteLinkErrorAlert = true
            }
        }
    }
    
    func handleEditLink(link: Link) {
        self.links = self.links.map() { item in
            if item.id == link.id {
                return link
            }
            else {
                return item
            }
        }
    }
    
    func handleDeleteCollection(collectionId: Int) {
        Task {
            await collectionsRepository.deleteCollection(id: collectionId) { del in
                self.progressIndicatorRepository.presenting = del
            } setSuccess: {
                self.allCollections = self.allCollections.filter() { $0.id != collectionId }
            } setError: { _ in
                self.deleteCollectionErrorAlert = true
            }
        }
    }
    
    func handleEditCollection(collection: Collection) {
        self.allCollections = self.allCollections.map() { item in
            if item.id == collection.id {
                return collection
            }
            else {
                return item
            }
        }
    }
    
    func handleDeleteTag(tagId: Int) async -> Bool {
        guard let instance = apiClientRepository.instance else { return false }
        let result = await instance.tags.deleteTag(tagId: tagId)
        if result.successful == true {
            await loadData(setLoading: false)
            return true;
        }
        else {
            return false;
        }
    }

}
