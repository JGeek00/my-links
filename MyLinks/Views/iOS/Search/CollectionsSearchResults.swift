import SwiftUI

struct CollectionsSearchResults: View {
    @Environment(SearchViewModel.self) private var searchViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        List(searchViewModel.filteredCollections, id: \.self) { item in
            CollectionItemComponent(collection: item, allowSharingOptions: item.ownerId == searchViewModel.loggedUserId, onTaskCompleted: { c, action in
                if action == .delete {
                    searchViewModel.handleDeleteCollection(collectionId: c.id)
                }
            }, onLinkTap: { link, mode in
                if let mode = mode {
                    searchViewModel.navigateDetail(link: link, mode: mode)
                }
                else if let urlString = link.url, let url = URL(string: urlString) {
                    openURL(url)
                }
            }, selectedLinkId: horizontalSizeClass == .regular ? searchViewModel.selectedLink?.link.id : nil)
        }
        .listStyle(.insetGrouped)
        .navigationTitle("All search results")
    }
}
