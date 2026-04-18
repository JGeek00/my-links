import SwiftUI

struct LinksSearchResults: View {
    @Environment(SearchViewModel.self) private var searchViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .regular {
            ScrollView {
                LazyVGrid(columns: Config.gridColumns) {
                    ForEach(searchViewModel.links, id: \.self) { item in
                        LinkItemComponent(item: item) {
                            Task { await searchViewModel.loadData() }
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
                LinkItemComponent(item: item) {
                    Task { await searchViewModel.loadData() }
                }
            }
            .navigationTitle("All search results")
        }
    }
}
