import SwiftUI

struct LinksFilteredRegularView: View {
    var mode: Enums.LinksFilteredMode
    
    init(mode: Enums.LinksFilteredMode) {
        self.mode = mode
    }
    
    @Environment(LinksFilteredViewModel.self) private var linksFilteredViewModel
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
        
    var body: some View {
        let subCollections = collectionsProvider.data.filter() { $0.parent?.id != nil && linksFilteredViewModel.input.id != nil && $0.parent!.id! == linksFilteredViewModel.input.id! }
        ScrollViewReader(content: { scrollView in
            ScrollView {
                if linksFilteredViewModel.input.mode == .collection && linksFilteredViewModel.input.id != nil && !subCollections.isEmpty {
                    let filteredSubCollections = linksFilteredViewModel.searchLinksValue != "" ? subCollections.filter() { $0.name!.lowercased().contains(linksFilteredViewModel.searchLinksValue.lowercased())} : subCollections
                    VStack(alignment: .leading) {
                        Text("Collections")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .padding(.leading, 8)
                        if filteredSubCollections.isEmpty {
                            ContentUnavailableView {
                                Label("No subcollections available.", systemImage: "magnifyingglass")
                            } description: {
                                Text("Change the inputted search term.")
                            }
                            .transition(.opacity)
                        }
                        else {
                            LazyVGrid(columns: Config.gridColumns) {
                                ForEach(filteredSubCollections, id: \.self) { item in
                                    CollectionItemComponent(collection: item) {
                                        collectionsProvider.deleteCollection(id: item.id!)
                                    }
                                    .padding(6)
                                }
                            }
                            .transition(.opacity)
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 14)
                }
                if !linksFilteredViewModel.data.isEmpty {
                    VStack(alignment: .leading) {
                        if linksFilteredViewModel.input.mode == .collection {
                            Text("Links")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .padding(.leading, 8)
                        }
                        LazyVGrid(columns: Config.gridColumns) {
                            ForEach(linksFilteredViewModel.data, id: \.self) { item in
                                LinkItemComponent(item: item) { link, action in
                                    linksFilteredViewModel.onTaskCompleted(link: link, action: action)
                                }
                                .onAppear {
                                    if item == linksFilteredViewModel.data.last {
                                        linksFilteredViewModel.loadMore()
                                    }
                                }
                                .padding(6)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 16)
                }
                else {
                    ContentUnavailableView {
                        Label(mode == .tag ? "This tag has no links" : "No links added to this collection", systemImage: "link")
                    } description: {
                        Text(mode == .tag ? "Add this tag to some links to see them here." : "Add some links to this collection to see them here.")
                    }
                    .transition(.opacity)
                }
            }
            .transition(.opacity)
        })
        .background(Color.listBackground)
    }
}

