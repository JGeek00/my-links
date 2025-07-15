import SwiftUI

struct CollectionsSearchResults: View {
    @EnvironmentObject private var searchViewModel: SearchViewModel
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    
    var body: some View {
        let collections = collectionsProvider.data.filter({ $0.name!.lowercased().contains((searchViewModel.searchQueryValue?.lowercased()) ?? "") })
        List(collections, id: \.self) { item in
            CollectionItemComponent(collection: item) {
                collectionsProvider.deleteCollection(id: item.id!)
            }
        }
        .navigationTitle("All search results")
    }
}
