import Foundation
import SwiftUI

@MainActor
@Observable
class LinksViewModel {
    let apiClientRepository: ApiClientRepository
    let linkManagerRepository: LinkManagerRepository
    
    init() {
        self.apiClientRepository = RepositoriesContainer.shared.apiClientRepository
        self.linkManagerRepository = RepositoriesContainer.shared.linkManagerRepository
    }
    
    var data: [Link] = []
    var loading = true
    var error = false
    
    var searchFieldValue = ""
    var searchPresented = false
    @ObservationIgnored var searchQueryValue: String? = nil
    @ObservationIgnored var previousSearch: String? = nil
    
    var loadingMore = false
    
    var sortingSelected = Enums.SortingOptions.dateNewestFirst
    
    // Flag to triger onChange
    var scrollTopList = false
    
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
        let result = await instance.links.searchLiks(cursor: cursor, searchQueryString: searchQueryValue, searchByName: searchQueryValue != nil ? true : nil, sort: sortingSelected.rawValue)
        if result.successful == true {
            DispatchQueue.main.async {
                if loadMore == true {
                    self.data = self.data + (result.data?.data?.links ?? [])
                }
                else {
                    self.data = result.data?.data?.links ?? []
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
        if loadingMore == true && !data.isEmpty {
            return
        }
        self.loadingMore = true
        Task {
            await loadData(cursor: data.last!.id, setError: false, loadMore: true)
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
    
    func removeLinkData(linkId: Int) {
        DispatchQueue.main.async {
            self.data = self.data.filter() { $0.id != linkId }
        }
    }
    
    func updateLinkData(link: Link) {
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
    
    func reload() {
        Task { await loadData() }
    }
}
