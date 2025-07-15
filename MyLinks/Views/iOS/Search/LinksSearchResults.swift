import SwiftUI

struct LinksSearchResults: View {
    @EnvironmentObject private var searchViewModel: SearchViewModel
    
    var body: some View {
        List(searchViewModel.links, id: \.self) { item in
            LinkItemComponent(item: item) { _, _ in }
        }
        .navigationTitle("All search results")
    }
}
