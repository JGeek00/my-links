import SwiftUI

struct TagsSearchResults: View {
    @State private var searchTagsViewModel: TagsViewModel
    
    init(searchQuery: String) {
        _searchTagsViewModel = State(initialValue: TagsViewModel(searchQuery: searchQuery))
    }
    
    @Environment(SearchViewModel.self) private var searchViewModel: SearchViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        Group {
            switch searchTagsViewModel.state {
            case .loading:
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .success(let data):
                if data.tags.isEmpty {
                    ContentUnavailableView {
                        Label("No tags found", systemImage: "tag")
                    } description: {
                        Text("Change the search term to see some tags.")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else {
                    if horizontalSizeClass == .regular {
                        ScrollView {
                            LazyVGrid(columns: Config.gridColumns) {
                                ForEach(data.tags, id: \.self) { item in
                                    TagItemComponent(tag: item) {
                                        Task { await searchTagsViewModel.deleteTag(tagId: item.id) }
                                    }
                                    .padding(6)
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    else {
                        List(data.tags, id: \.self) { item in
                            TagItemComponent(tag: item) {
                                Task { await searchTagsViewModel.deleteTag(tagId: item.id) }
                            }
                        }
                        .animation(.default, value: data.tags)
                    }
                }

            case .failure:
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.circle")
                } description: {
                    Text("An error occured when loading the links data. Check your Internet connection and try again later.")
                    Button {
                        Task { await searchTagsViewModel.loadData(setLoading: true) }
                    } label: {
                        Label("Retry", systemImage: "arrow.counterclockwise")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.listBackground)
        .navigationTitle("All search results")
        .navigationBarTitleDisplayMode(.inline)
    }
}
