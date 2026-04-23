import Foundation
import SwiftUI

@MainActor
@Observable
class TagsViewModel {
    @ObservationIgnored private let apiClientRepository: ApiClientRepository
    
    var initialSearchQuery: String? = nil   // Used on the search results view
    
    init(searchQuery: String? = nil, apiClientRepository: ApiClientRepository = RepositoriesContainer.shared.apiClientRepository) {
        self.apiClientRepository = apiClientRepository
        self.initialSearchQuery = searchQuery
    }
    
    var loading: Bool = true
    var data: [TagsResponse_DataClass_Tag] = []
    var error = false
    
    @ObservationIgnored private var nextBatch: Int? = nil
    @ObservationIgnored private var loadingMore: Bool = false
    
    var searchFieldValue = ""
    var searchPresented = false
    @ObservationIgnored var searchQueryValue: String? = nil
    @ObservationIgnored var previousSearch: String? = nil
    
    private func loadData(setLoading: Bool = false, page: Int? = nil, loadingMore: Bool = false) async {
        if setLoading == true {
            self.loading = true
        }
        guard let instance = apiClientRepository.instance else { return }
        let result = await instance.tags.fetchTags(page: page, search: initialSearchQuery ?? searchQueryValue)
        if let data = result.data?.data {
            DispatchQueue.main.async {
                self.nextBatch = data.nextCursor
                withAnimation {
                    if loadingMore == true {
                        self.data = self.data + data.tags
                    }
                    else {
                        self.data = data.tags
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
                self.error = true
                self.loading = false
            }
        }
    }
    
    func initialLoad() async {
        if data.isEmpty {
            await loadData(setLoading: true)
        }
    }
    
    func refresh() async {
        await loadData(setLoading: false)
    }
    
    func loadNextPage() {
        if let nextBatch = nextBatch, !loadingMore {
            Task {
                self.loadingMore = true
                await loadData(page: nextBatch)
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
    
    func createTag(name: String) async -> Bool {
        guard let instance = apiClientRepository.instance else { return false }
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
