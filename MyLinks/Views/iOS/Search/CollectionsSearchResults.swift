import SwiftUI

struct CollectionsSearchResults: View {
    @EnvironmentObject private var searchViewModel: SearchViewModel
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        let collections = collectionsProvider.data.filter({ $0.name!.lowercased().contains((searchViewModel.searchQueryValue?.lowercased()) ?? "") })
        if horizontalSizeClass == .regular {
            ScrollView {
                LazyVGrid(columns: Config.gridColumns) {
                    ForEach(collections, id: \.self) { item in
                        CollectionItemComponent(collection: item) {
                            collectionsProvider.deleteCollection(id: item.id!)
                        }
                        .padding(8)
                    }
                }
                .padding(16)
            }
            .navigationTitle("All search results")
            .background(Color.listBackground)
        }
        else {
            List(collections, id: \.self) { item in
                CollectionItemComponent(collection: item) {
                    collectionsProvider.deleteCollection(id: item.id!)
                }
            }
            .navigationTitle("All search results")
        }
    }
}
