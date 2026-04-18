import Foundation
import SwiftUI

@MainActor
class SearchViewModel: ObservableObject {
    @Published var links: [Link] = []
    @Published var loading = false
    @Published var error = false
    
    @Published var searchFieldValue = ""
    @Published var searchPresented = false
    var searchQueryValue: String? = nil
    var previousSearch: String? = nil
    
    @Published var loadingMore = false
    
    @Published var sortingSelected = Enums.SortingOptions.dateNewestFirst
    
    // Flag to triger onChange
    @Published var scrollTopList = false
    
    init() {}
    
    func loadData(
        cursor: Int? = nil,
        setLoading: Bool = false,
        setError: Bool = true,
        loadMore: Bool = false
    ) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = ApiClientProvider.shared.instance else { return }
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
                ApiClientProvider.shared.destroy()
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
    
    func removeLinkData(linkId: Int) {
        DispatchQueue.main.async {
            self.links = self.links.filter() { $0.id != linkId }
        }
    }
    
    func updateLinkData(link: Link) {
        DispatchQueue.main.async {
            self.links = self.links.map() { item in
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
        Task { await DashboardViewModel.shared.loadData() }
    }
    
    func reset() {
        self.links = []
        self.loading = true
        self.error = false
        self.searchFieldValue = ""
        self.searchPresented = false
        self.searchQueryValue = nil
        self.previousSearch = nil
        self.loadingMore = false
        self.sortingSelected = .dateNewestFirst
    }
}
