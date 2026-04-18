import SwiftUI

struct CollectionsSearchResults: View {
    @Environment(SearchViewModel.self) private var searchViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        let collections = searchViewModel.collections.filter({ $0.name.lowercased().contains((searchViewModel.searchQueryValue?.lowercased()) ?? "") })
        if horizontalSizeClass == .regular {
            ScrollView {
                LazyVGrid(columns: Config.gridColumns) {
                    ForEach(collections, id: \.self) { item in
                        CollectionItemComponent(collection: item) {
                            // TODO: refresh collections
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
                   // TODO: refresh collections
                }
            }
            .navigationTitle("All search results")
        }
    }
}
