import Foundation
import SwiftUI

@MainActor
@Observable
class LinksViewModel {
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    @ObservationIgnored private let linkManagerRepository: LinkManagerRepository
    @ObservationIgnored private let progressIndicatorRepository: ProgressIndicatorRepository
    
    var initialSearchQuery: String? = nil   // Used on the search results view
    
    init(searchQuery: String? = nil, apiClientRepository: ApiClientRepository = RepositoriesContainer.shared.apiClientRepository, linkManagerRepository: LinkManagerRepository =  RepositoriesContainer.shared.linkManagerRepository, progressIndicatorRepository: ProgressIndicatorRepository = RepositoriesContainer.shared.progressIndicatorRepository) {
        self.apiClientRepository = apiClientRepository
        self.linkManagerRepository = linkManagerRepository
        self.progressIndicatorRepository = progressIndicatorRepository
        self.initialSearchQuery = searchQuery
    }
    
    var data: [Link] = []
    var loading = true
    var error = false
    
    var searchFieldValue = ""
    var searchPresented = false
    @ObservationIgnored var searchQueryValue: String? = nil
    @ObservationIgnored var previousSearch: String? = nil
    
    @ObservationIgnored private var loadingMore = false
    @ObservationIgnored private var nextBatch: Int? = nil
    
    var sortingSelected = Enums.SortingOptions.dateNewestFirst
    
    // Flag to triger onChange
    var scrollTopList = false
    
    var deleteLinkErrorAlert = false
    
    private func loadData(
        cursor: Int? = nil,
        setLoading: Bool = false,
        setError: Bool = true,
        loadingMore: Bool = false
    ) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = apiClientRepository.instance else { return }
        let result = await instance.links.searchLiks(cursor: cursor, searchQueryString: initialSearchQuery ?? searchQueryValue, searchByName: initialSearchQuery != nil || searchQueryValue != nil ? true : nil, sort: sortingSelected.rawValue)
        if let data = result.data?.data {
            self.nextBatch = data.nextCursor
            DispatchQueue.main.async {
                withAnimation(.default) {
                    if loadingMore == true {
                        self.data = self.data + data.links
                    }
                    else {
                        self.data = data.links
                    }
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
    
    func loadInitial() async {
        if data.isEmpty {
            await loadData(setLoading: true)
        }
    }
    
    func refresh() async {
        await loadData(setLoading: false)
    }
    
    func loadMore() {
        if let nextBatch = nextBatch, !loadingMore {
            Task {
                self.loadingMore = true
                await loadData(cursor: nextBatch, setError: false, loadingMore: true)
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
    
    func handleCreatedLink(link: Link) {
        // Request is done by the form view model
        self.data.insert(link, at: 0)
    }
    
    func handleDeleteLink(linkId: Int) {
        Task {
            await linkManagerRepository.deleteLink(id: linkId) { processing in
                self.progressIndicatorRepository.presenting = processing
            } onSuccess: { _ in
                self.data = self.data.filter() { $0.id != linkId }
            } onError: {
                self.deleteLinkErrorAlert = true
            }
        }
    }
    
    func handleEditLink(link: Link) {
        // Request is done by the form view model
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
