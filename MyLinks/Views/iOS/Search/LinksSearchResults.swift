import SwiftUI

struct LinksSearchResults: View {
    @State private var searchLinksViewModel: LinksViewModel
    
    init(searchQuery: String) {
        _searchLinksViewModel = State(initialValue: LinksViewModel(searchQuery: searchQuery))
    }
    
    @Environment(SearchViewModel.self) private var searchViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        Group {
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
                            .onAppear {
                                if item == searchLinksViewModel.data.last {
                                    searchLinksViewModel.loadMore()
                                }
                            }
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
                    .onAppear {
                        if item == searchLinksViewModel.data.last {
                            searchLinksViewModel.loadMore()
                        }
                    }
                }
                .navigationTitle("All search results")
            }
        }
        .task {
            await searchLinksViewModel.loadData()
        }
    }
}
