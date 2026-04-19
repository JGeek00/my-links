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
    var loading = false
    var error = false
    
    var collections: [Collection] {
        get { collectionsRepository.data }
        set { collectionsRepository.data = newValue }
    }
    
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
        cursor: Int? = nil,
        setLoading: Bool = false,
        setError: Bool = true,
        loadMore: Bool = false
    ) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = apiClientRepository.instance else { return }
        let result = await instance.links.fetchLinks(cursor: cursor, searchQueryString: searchQueryValue, searchByName: searchQueryValue != nil ? true : nil, sort: sortingSelected.rawValue)
        if result.successful == true {
            DispatchQueue.main.async {
                if loadMore == true {
                    self.links = self.links + (result.data?.response ?? [])
                }
                else {
                    self.links = result.data?.response ?? []
                }
                withAnimation(.default) {
                    self.loading = false
                    self.error = false
                }
            }
        }
        else {
            if result.statusCode == 401 {
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
    
    func loadMore() {
        if loadingMore == true && !links.isEmpty {
            return
        }
        self.loadingMore = true
        Task {
            await loadData(cursor: links.last!.id, setError: false, loadMore: true)
            DispatchQueue.main.async {
                self.loadingMore = false
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
                self.collections = self.collections.filter() { $0.id != collectionId }
            } setError: { _ in
                self.deleteCollectionErrorAlert = true
            }
        }
    }
    
    func handleEditCollection(collection: Collection) {
        self.collections = self.collections.map() { item in
            if item.id == collection.id {
                return collection
            }
            else {
                return item
            }
        }
    }
}
