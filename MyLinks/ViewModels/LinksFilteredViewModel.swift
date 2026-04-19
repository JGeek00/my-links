import Foundation
import SwiftUI

@MainActor
@Observable
class LinksFilteredViewModel {
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    @ObservationIgnored private let linkManagerRepository: LinkManagerRepository
    @ObservationIgnored private let collectionsRepository: CollectionsRepository
    @ObservationIgnored private let progressIndicatorRepository: ProgressIndicatorRepository
    @ObservationIgnored var input: LinksFilteredRequest
    
    init(input: LinksFilteredRequest) {
        self.apiClientRepository = RepositoriesContainer.shared.apiClientRepository
        self.collectionsRepository = RepositoriesContainer.shared.collectionsRepository
        self.linkManagerRepository = RepositoriesContainer.shared.linkManagerRepository
        self.progressIndicatorRepository = RepositoriesContainer.shared.progressIndicatorRepository
        self.input = input
        
        self.collections = collectionsRepository.data
    }
    
    init(apiClientRepository: ApiClientRepository, linkManagerRepository: LinkManagerRepository, collectionsRepository: CollectionsRepository, progressIndicatorRepository: ProgressIndicatorRepository, input: LinksFilteredRequest) {
        self.apiClientRepository = apiClientRepository
        self.collectionsRepository = collectionsRepository
        self.linkManagerRepository = linkManagerRepository
        self.progressIndicatorRepository = progressIndicatorRepository
        self.input = input
        
        self.collections = collectionsRepository.data
    }
    
    var collections: [Collection] = []
        
    var data: [Link] = []
    var loading = true
    var error = false
    
    var searchLinksValue = ""
    var searchLinksPresented = false
    @ObservationIgnored var previousLinksSearch: String? = nil
    
    var searchCollectionsValue = ""
    
    var loadingMore = false
    
    var sortingSelected = Enums.SortingOptions.dateNewestFirst
    
    var deleteLinkErrorAlert = false    
    var deleteCollectionErrorAlert = false
    
    func loadData(
        cursor: Int? = nil,
        setLoading: Bool = false,
        setError: Bool = true,
        loadMore: Bool = false,
        searchTerm: String? = nil
    ) async {
        if (input.mode == .collection || input.mode == .tag) && input.id == nil {
            return
        }
        
        if setLoading == true {
            self.loading = true
        }
        guard let instance = apiClientRepository.instance else { return }
        let result = await instance.links.searchLiks(
            cursor: cursor,
            collectionId: input.mode == .collection ? input.id! : nil,
            tagId: input.mode == .tag ? input.id! : nil,
            pinnedOnly: input.mode == .pinned ? true : nil,
            recentOnly: input.mode == .recent ? true : nil,
            searchQueryString: searchTerm,
            searchByName: searchTerm != nil ? true : nil,
            sort: sortingSelected.rawValue
        )
        if result.successful == true {
            DispatchQueue.main.async {
                if loadMore == true {
                    self.data = self.data + (result.data?.data?.links ?? [])
                }
                else {
                    self.data = result.data?.data?.links ?? []
                }
            }
            // The duration of the list animation
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) {
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
        if loadingMore == true && !data.isEmpty {
            return
        }
        self.loadingMore = true
        Task {
            await loadData(cursor: data.last!.id, setError: false, loadMore: true, searchTerm: searchLinksValue)
            DispatchQueue.main.async {
                self.loadingMore = false
            }
        }
    }
    
    func searchLinks() {
        Task {
            await loadData(setLoading: true, searchTerm: searchLinksValue)
            self.previousLinksSearch = searchLinksValue
        }
    }

    func clearLinksSearch() {
        if previousLinksSearch != nil {
            Task {
                await loadData(setLoading: true, searchTerm: nil)
                self.previousLinksSearch = nil
            }
        }
    }
    
    func handleCreatedLink(link: Link) {
        // Request is done by the form view model
        DispatchQueue.main.async {
            self.data.insert(link, at: 0)
        }
    }
    
    func handleDeleteLink(linkId: Int) {
        Task {
            await linkManagerRepository.deleteLink(id: linkId) { processing in
                DispatchQueue.main.async {
                    self.progressIndicatorRepository.presenting = processing
                }
            } onSuccess: { _ in
                DispatchQueue.main.async {
                    self.data = self.data.filter() { $0.id != linkId }
                }
            } onError: {
                DispatchQueue.main.async {
                    self.deleteLinkErrorAlert = true
                }
            }
        }
    }
    
    func handleEditLink(link: Link) {
        // Request is being handled in the form view model
        DispatchQueue.main.async {
            self.data = self.data.map() { item in
                if item.id == link.id {
                    return link
                }
                else {
                    return item
                }
            }
        }
    }
    
    func handleCollectionCreated(collection: Collection) {
        var newData = self.collections + [collection]
        newData = newData.sorted() { $0.name.lowercased() < $1.name.lowercased() }
        self.collections = newData
    }
    
    func handleDeleteCollection(collectionId: Int) {
        Task {
            await collectionsRepository.deleteCollection(id: collectionId) { progress in
                self.progressIndicatorRepository.presenting = progress
            } setSuccess: {
                DispatchQueue.main.async {
                    self.collections = self.collections.filter() { $0.id != collectionId }
                }
            } setError: { _ in
                DispatchQueue.main.async {
                    self.deleteCollectionErrorAlert = true
                }
            }
        }
    }
    
    func handleEditCollection(collection: Collection) {
        // Request is being handled in the form view model
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
