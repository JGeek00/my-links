import SwiftUI

struct TagsSearchResults: View {
    @State private var searchTagsViewModel: TagsViewModel
    
    init(searchQuery: String) {
        _searchTagsViewModel = State(initialValue: TagsViewModel(searchQuery: searchQuery))
    }
    
    @Environment(SearchViewModel.self) private var searchViewModel: SearchViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        TagsList(
            loading: searchTagsViewModel.loading,
            error: searchTagsViewModel.error,
            withSearch: searchTagsViewModel.searchQueryValue != nil,
            data: searchTagsViewModel.data,
            onReload: {
                Task { await searchTagsViewModel.initialLoad() }
            },
            onDeleteTag: { tag in
                Task { await searchTagsViewModel.deleteTag(tagId: tag.id) }
            },
            onLoadNextBatch: {
                searchTagsViewModel.loadNextPage()
            }
        )
        .background(Color.listBackground)
        .navigationTitle("All search results")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await searchTagsViewModel.refresh()
        }
        .task {
            await searchTagsViewModel.initialLoad()
        }
    }
}
