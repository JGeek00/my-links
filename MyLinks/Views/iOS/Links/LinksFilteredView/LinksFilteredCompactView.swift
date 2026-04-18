import SwiftUI

struct LinksFilteredCompactView: View {
    var mode: Enums.LinksFilteredMode
    
    init(mode: Enums.LinksFilteredMode) {
        self.mode = mode
    }
    
    @Environment(LinksFilteredViewModel.self) private var linksFilteredViewModel
       
    var body: some View {
        let subCollections = linksFilteredViewModel.collections.filter() { $0.parent?.id != nil && linksFilteredViewModel.input.id != nil && $0.parent!.id! == linksFilteredViewModel.input.id! }
        
        ScrollViewReader { scrollView in
            if linksFilteredViewModel.loading == false && linksFilteredViewModel.error == false && linksFilteredViewModel.data.isEmpty && subCollections.isEmpty {
                // Show when no links and no subcategories
                ContentUnavailableView {
                    Label(mode == .tag ? "This tag has no links" : "No links added to this collection", systemImage: "link")
                } description: {
                    Text(mode == .tag ? "Add this tag to some links to see them here." : "Add some links to this collection to see them here.")
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            }
            else {
                List {
                    if linksFilteredViewModel.input.mode == .collection && linksFilteredViewModel.input.id != nil && !subCollections.isEmpty {
                        let filteredSubCollections = linksFilteredViewModel.searchLinksValue != "" ? subCollections.filter() { $0.name.lowercased().contains(linksFilteredViewModel.searchLinksValue.lowercased())} : subCollections
                        Section("Subcollections") {
                            if filteredSubCollections.isEmpty {
                                ContentUnavailableView {
                                    Label("No subcollections available.", systemImage: "magnifyingglass")
                                } description: {
                                    Text("Change the inputted search term.")
                                }
                                .transition(.opacity)
                            }
                            else {
                                ForEach(filteredSubCollections, id: \.self) { item in
                                    CollectionItemComponent(collection: item) {
                                        Task { await linksFilteredViewModel.loadData() }
                                    }
                                }
                                .transition(.opacity)
                            }
                        }
                    }
                    if linksFilteredViewModel.data.isEmpty {
                        // Show when subcategories but no links
                        ContentUnavailableView {
                            Label(mode == .tag ? "This tag has no links" : "No links added to this collection", systemImage: "link")
                        } description: {
                            Text(mode == .tag ? "Add this tag to some links to see them here." : "Add some links to this collection to see them here.")
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    else {
                        Section("Links") {
                            ForEach(linksFilteredViewModel.data, id: \.self) { item in
                                LinkItemComponent(item: item) {
                                    Task { await linksFilteredViewModel.loadData() }
                                }
                                .onAppear {
                                    if item == linksFilteredViewModel.data.last {
                                        linksFilteredViewModel.loadMore()
                                    }
                                }
                            }
                        }
                    }
                }
                .animation(.default, value: linksFilteredViewModel.data)
                .animation(.default, value: subCollections)
            }
        }
    }
}

