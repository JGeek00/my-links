import Foundation
import SwiftUI

@MainActor
class LinksFilteredViewModel: ObservableObject {
    @Published var input: LinksFilteredRequest
    
    init(input: LinksFilteredRequest) {
        self.input = input
    }
    
    @Published var data: [Link] = []
    @Published var loading = true
    @Published var error = false
    
    @Published var searchLinksValue = ""
    @Published var searchLinksPresented = false
    var previousLinksSearch: String? = nil
    
    @Published var searchCollectionsValue = ""
    
    @Published var loadingMore = false
    
    @Published var sortingSelected = Enums.SortingOptions.dateNewestFirst
    
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
        guard let instance = ApiClientProvider.shared.instance else { return }
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
    
    func onTaskCompleted(link: Link, action: Enums.LinkTaskCompleted) {
        switch action {
        case .delete:
            removeLinkData(linkId: link.id)
        case .pin:
            updateLinkData(link: link)
        case .edit:
            updateLinkData(link: link)
        case .create:
            return
        }
    }
    
    func removeLinkData(linkId: Int) {
        DispatchQueue.main.async {
            self.data = self.data.filter() { $0.id != linkId }
        }
    }
    
    func updateLinkData(link: Link) {
        DispatchQueue.main.async {
            if self.input.mode == .tag {
                let contains = link.tags.first { $0.id == self.input.id }
                if contains == nil {
                    self.data = self.data.filter() { $0.id != link.id }
                }
                else {
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
            else if self.input.mode == .collection {
                if link.collection.id != self.input.id {
                    self.data = self.data.filter() { $0.id != link.id }
                }
                else {
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
            else {
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
    }
    
    func reload() {
        Task { await loadData() }
        Task { await DashboardViewModel.shared.loadData() }
        Task {
            await LinksViewModel.shared.loadData()
            LinksViewModel.shared.scrollTopList.toggle()
        }
    }
}
