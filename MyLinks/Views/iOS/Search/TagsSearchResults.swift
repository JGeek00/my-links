import SwiftUI

struct TagsSearchResults: View {
    @EnvironmentObject private var searchViewModel: SearchViewModel
    @EnvironmentObject private var tagsProvider: TagsProvider
    
    var body: some View {
        let tags = tagsProvider.data.filter({ $0.name!.lowercased().contains((searchViewModel.searchQueryValue?.lowercased()) ?? "") })
        List(tags, id: \.self) { item in
            TagItemComponent(tag: item)
        }
        .navigationTitle("All search results")
    }
}
