import SwiftUI

struct CollectionsSearchResults: View {
    @Environment(SearchViewModel.self) private var searchViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .regular {
            ScrollView {
                LazyVGrid(columns: Config.gridColumns) {
                    ForEach(searchViewModel.filteredCollections, id: \.self) { item in
                        CollectionItemComponent(collection: item) { c, action in
                            switch action {
                            case .edit:
                                searchViewModel.handleEditCollection(collection: c)
                            case .delete:
                                searchViewModel.handleDeleteCollection(collectionId: c.id)
                            }
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
            List(searchViewModel.filteredCollections, id: \.self) { item in
                CollectionItemComponent(collection: item) { c, action in
                    switch action {
                    case .edit:
                        searchViewModel.handleEditCollection(collection: c)
                    case .delete:
                        searchViewModel.handleDeleteCollection(collectionId: c.id)
                    }
                }
            }
            .navigationTitle("All search results")
        }
    }
}
