import SwiftUI

struct LinksSearchResults: View {
    @State private var searchLinksViewModel: LinksViewModel
    
    init(searchQuery: String) {
        _searchLinksViewModel = State(initialValue: LinksViewModel(searchQuery: searchQuery))
    }
    
    @Environment(SearchViewModel.self) private var searchViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        LinksList(
            loading: searchLinksViewModel.loading,
            error: searchLinksViewModel.error,
            withSearch: searchLinksViewModel.searchQueryValue != nil,
            data: searchLinksViewModel.data,
            scrollToTop: searchLinksViewModel.scrollTopList,
            onEditLink: { link in
                searchLinksViewModel.handleEditLink(link: link)
            },
            onDeleteLink: { link in
                searchLinksViewModel.handleDeleteLink(linkId: link.id)
            },
            onLoadMore: {
                searchLinksViewModel.loadMore()
            },
            onReload: {
                Task { await searchLinksViewModel.loadInitial() }
            }
        )
        .navigationTitle("All search results")
        .background(Color.listBackground)
        .refreshable {
            await searchLinksViewModel.loadInitial()
        }
        .task {
            await searchLinksViewModel.loadInitial()
        }
    }
}
