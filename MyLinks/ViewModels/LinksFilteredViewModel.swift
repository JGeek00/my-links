import Foundation
import SwiftUI

@MainActor
@Observable
class LinksFilteredViewModel {
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    @ObservationIgnored private let linkManagerRepository: LinkManagerRepository
    @ObservationIgnored private let collectionsRepository: CollectionsRepository
    @ObservationIgnored var input: LinksFilteredRequest
    
    init(apiClientRepository: ApiClientRepository = RepositoriesContainer.shared.apiClientRepository, linkManagerRepository: LinkManagerRepository = RepositoriesContainer.shared.linkManagerRepository, collectionsRepository: CollectionsRepository = RepositoriesContainer.shared.collectionsRepository, input: LinksFilteredRequest) {
        self.apiClientRepository = apiClientRepository
        self.collectionsRepository = collectionsRepository
        self.linkManagerRepository = linkManagerRepository
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
    var pinUnpinLinkErrorAlert = false
    var editLinkErrorAlert = false
    
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
    
    func deleteLink(link: Link) {
        Task {
            await linkManagerRepository.deleteLink(id: link.id) { _ in
                Task { await self.loadData() }
            } onError: {
                self.deleteLinkErrorAlert = true
            }
        }
    }
    
    func pinUnpinLink(link: Link) {
        Task {
            await linkManagerRepository.pinUnpinLink(link: link) { result in
                Task { await self.loadData() }
            } onError: {
                self.pinUnpinLinkErrorAlert = true
            }
        }
    }
    
    func editLink(link: Link) {
        Task {
            let tags = link.tags.map() { TagCreation(name: $0.name) }
            let collection = CollectionCreation(id: link.collection.id, name: link.collection.name, ownerId: link.collection.ownerId)
            let pinnedBy = link.pinnedBy.map() { PinnedByRequestEditing(id: $0.id) }
            let body = LinkEditingRequest(tags: tags, collection: collection, pinnedBy: pinnedBy, image: link.image, pdf: link.pdf)
            await linkManagerRepository.editLink(id: link.id, body: body) { linkResult in
                Task { await self.loadData() }
            } onError: { statusCode in
                self.editLinkErrorAlert = true
            }
        }
    }
    
}
