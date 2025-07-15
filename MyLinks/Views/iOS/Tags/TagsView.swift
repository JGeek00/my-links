import SwiftUI
import CustomAlert

struct TagsView: View {
    @EnvironmentObject private var tagsProvider: TagsProvider
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var searchText = ""
    
    var body: some View {
        let searched = searchText != "" ? tagsProvider.data.filter() { $0.name!.lowercased().contains(searchText.lowercased()) } : tagsProvider.data
        Group {
            if horizontalSizeClass == .regular {
                ScrollView {
                    LazyVGrid(columns: Config.gridColumns) {
                        ForEach(searched, id: \.self) { item in
                            TagItemComponent(tag: item)
                                .padding(6)
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .overlay(alignment: .center) {
                    if tagsProvider.data.isEmpty {
                        ContentUnavailableView {
                            Label("No tags created", systemImage: "tag")
                        } description: {
                            Text("Add tags to links to see them here.")
                        }
                    }
                }
                .overlay(alignment: .center) {
                    if searched.isEmpty {
                        ContentUnavailableView {
                            Label("No tags found", systemImage: "tag")
                        } description: {
                            Text("Change the search term to see some tags.")
                        }
                    }
                }
            }
            else {
                List(searched, id: \.self) { item in
                    TagItemComponent(tag: item)
                }
                .animation(.default, value: searched)
                .overlay(alignment: .center) {
                    if tagsProvider.data.isEmpty {
                        ContentUnavailableView {
                            Label("No tags created", systemImage: "tag")
                        } description: {
                            Text("Add tags to links to see them here.")
                        }
                    }
                }
                .overlay(alignment: .center) {
                    if searched.isEmpty && searchText != "" {
                        ContentUnavailableView {
                            Label("No tags found", systemImage: "tag")
                        } description: {
                            Text("Change the search term to see some tags.")
                        }
                    }
                }
            }
        }
        .navigationTitle("Tags")
        .refreshable {
            await tagsProvider.loadData()
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .overlay(alignment: .center) {
            TagsIndicators()
        }
    }
}

fileprivate struct TagsIndicators: View {
    @EnvironmentObject private var tagsProvider: TagsProvider
    
    init() {}
    
    var body: some View {
        if tagsProvider.loading == true || tagsProvider.error == true {
            Group {
                if tagsProvider.loading == true {
                    Group {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if tagsProvider.error == true {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.circle")
                    } description: {
                        Text("An error occured when loading the links data. Check your Internet connection and try again later.")
                        Button {
                            Task { await tagsProvider.loadData(setLoading: true) }
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .background(Color.listBackground)
        }
    }
}
