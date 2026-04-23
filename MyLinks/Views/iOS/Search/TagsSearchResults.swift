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
                searchTagsViewModel.deleteTag(tagId: tag.id)
            }, onEditTag: { tag in
                searchTagsViewModel.handleEditTag(tag: tag)
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
        .alert("Error", isPresented: $searchTagsViewModel.deleteTagErrorAlert) {
            Button("OK", role: .cancel) {
                searchTagsViewModel.deleteTagErrorAlert = false
            }
        } message: {
            Text("The tag could not be deleted. Try again later.")
        }
    }
}
