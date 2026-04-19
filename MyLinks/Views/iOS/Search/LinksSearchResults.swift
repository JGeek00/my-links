import SwiftUI

struct LinksSearchResults: View {
    @Environment(SearchViewModel.self) private var searchViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .regular {
            ScrollView {
                LazyVGrid(columns: Config.gridColumns) {
                    ForEach(searchViewModel.links, id: \.self) { item in
                        LinkItemComponent(item: item) { l, id, action in
                            switch action {
                            case .edit:
                                searchViewModel.handleEditLink(link: l!)
                            case .delete:
                                searchViewModel.handleDeleteLink(linkId: id!)
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
            List(searchViewModel.links, id: \.self) { item in
                LinkItemComponent(item: item) { l, id, action in
                    switch action {
                    case .edit:
                        searchViewModel.handleEditLink(link: l!)
                    case .delete:
                        searchViewModel.handleDeleteLink(linkId: id!)
                    }
                }
            }
            .navigationTitle("All search results")
        }
    }
}
