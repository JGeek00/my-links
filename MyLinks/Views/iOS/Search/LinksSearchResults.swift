import SwiftUI

struct LinksSearchResults: View {
    @EnvironmentObject private var searchViewModel: SearchViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .regular {
            ScrollView {
                LazyVGrid(columns: Config.gridColumns) {
                    ForEach(searchViewModel.links, id: \.self) { item in
                        LinkItemComponent(item: item) { _, _ in }
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
                LinkItemComponent(item: item) { _, _ in }
            }
            .navigationTitle("All search results")
        }
    }
}
