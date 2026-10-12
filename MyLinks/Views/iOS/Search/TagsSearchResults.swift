import SwiftUI

struct TagsSearchResults: View {
    @State private var searchTagsViewModel: TagsViewModel
    
    let showSelectedLink: Bool
    
    init(searchQuery: String, showSelectedLink: Bool) {
        _searchTagsViewModel = State(initialValue: ListViewModelStore.shared.tagsViewModel(searchQuery: searchQuery))
        self.showSelectedLink = showSelectedLink
    }
    
    @Environment(SearchViewModel.self) private var searchViewModel: SearchViewModel
    @Environment(\.openURL) private var openURL
    
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
            },
            onLinkTap: { link, mode in
                if let mode = mode {
                    searchViewModel.navigateDetail(link: link, mode: mode)
                }
                else if let urlString = link.url, let url = URL(string: urlString) {
                    openURL(url)
                }
            },
            selectedLinkId: showSelectedLink ? searchViewModel.selectedLink?.link.id : nil
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
