import SwiftUI

struct TagsSearchResults: View {
    @EnvironmentObject private var searchViewModel: SearchViewModel
    @EnvironmentObject private var tagsProvider: TagsProvider
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        let tags = tagsProvider.data.filter({ $0.name!.lowercased().contains((searchViewModel.searchQueryValue?.lowercased()) ?? "") })
        if horizontalSizeClass == .regular {
            ScrollView {
                LazyVGrid(columns: Config.gridColumns) {
                    ForEach(tags, id: \.self) { item in
                        TagItemComponent(tag: item)
                        .padding(8)
                    }
                }
                .padding(16)
            }
            .navigationTitle("All search results")
            .background(Color.listBackground)
        }
        else {
            List(tags, id: \.self) { item in
                TagItemComponent(tag: item)
            }
            .navigationTitle("All search results")
        }
    }
}
