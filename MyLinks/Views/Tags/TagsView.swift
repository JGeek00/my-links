import SwiftUI
import CustomAlert

struct TagsView: View {
    @EnvironmentObject private var tagsProvider: TagsProvider
    
    init() {}
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var navigationPath = NavigationPath()
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                else {
                    let filtered = tagsProvider.data.filter() { $0.id != nil && $0.name != nil && $0.createdAt != nil }
                    if filtered.isEmpty {
                        ContentUnavailableView {
                            Label("No tags created", systemImage: "tag")
                        } description: {
                            Text("Add tags to links to see them here.")
                        }
                    }
                    else {
                        let searched = searchText != "" ? filtered.filter() { $0.name!.lowercased().contains(searchText.lowercased()) } : filtered
                        if !searched.isEmpty {
                            if horizontalSizeClass == .regular {
                                ScrollView {
                                    LazyVGrid(columns: Config.gridColumns) {
                                        ForEach(searched, id: \.self) { item in
                                            TagItemComponent(tag: item) {
                                                navigationPath.append(LinksFilteredRequest(name: item.name!, mode: .tag, id: item.id!))
                                            }
                                            .padding(6)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                }
                            }
                            else {
                                List(searched, id: \.self) { item in
                                    TagItemComponent(tag: item) {
                                        navigationPath.append(LinksFilteredRequest(name: item.name!, mode: .tag, id: item.id!))
                                    }
                                }
                                .animation(.default, value: searched)
                            }
                        }
                        else {
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
            .background(Color.listBackground)
            .navigationDestination(for: LinksFilteredRequest.self) { value in
                LinksFilteredView(input: value)
            }
        }
    }
}
