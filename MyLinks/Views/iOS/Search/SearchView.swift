import SwiftUI

struct SearchView: View {    
    @State private var searchViewModel: SearchViewModel
    
    init() {
        _searchViewModel = State(initialValue: SearchViewModel())
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        @Bindable var searchViewModel = searchViewModel

        GeometryReader { proxy in
            NavigationSplitView(preferredCompactColumn: $searchViewModel.preferredColumn) {
                NavigationStack {
                    Group {
                        if searchViewModel.searchQueryValue == nil {
                            ContentUnavailableView("Insert search term", systemImage: "magnifyingglass", description: Text("Input a search term to search links, categories and tags"))
                                .transition(.opacity)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        else {
                            if searchViewModel.loading == true {
                                ProgressView()
                                    .transition(.opacity)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            if searchViewModel.error == true {
                                ContentUnavailableView {
                                    Label("Error", systemImage: "exclamationmark.circle")
                                } description: {
                                    Text("An error occured when loading the dashboard data. Check your Internet connection and try again later.")
                                    Button {
                                        Task { await searchViewModel.loadData() }
                                    } label: {
                                        Label("Retry", systemImage: "arrow.counterclockwise")
                                    }
                                }
                                .transition(.opacity)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            if searchViewModel.loading == false && searchViewModel.error == false {
                                SerachContent()
                            }
                        }
                    }
                    .if(horizontalSizeClass == .regular) { view in
                        view
                            .background(Color.listBackground)
                    }
                    .background(Color.listBackground)
                    .navigationTitle("Search")
                    .searchable(text: $searchViewModel.searchFieldValue, isPresented: $searchViewModel.searchPresented)
                    .onSubmit(of: .search) {
                        searchViewModel.search()
                    }
                    .onChange(of: searchViewModel.searchPresented, { oldValue, newValue in
                        if oldValue == true && newValue == false {
                            searchViewModel.clearSearch()
                        }
                    })
                    .alert("Error", isPresented: $searchViewModel.deleteCollectionErrorAlert) {
                        Button("OK", role: .cancel) {
                            searchViewModel.deleteCollectionErrorAlert = false
                        }
                    } message: {
                        Text("The collection could not be deleted. Try again later.")
                    }
                    .alert("Error", isPresented: $searchViewModel.deleteLinkErrorAlert) {
                        Button("OK", role: .cancel) {
                            searchViewModel.deleteLinkErrorAlert = false
                        }
                    } message: {
                        Text("The link could not be deleted. Try again later.")
                    }
                    .alert("Error", isPresented: $searchViewModel.deleteTagErrorAlert) {
                        Button("OK", role: .cancel) {
                            searchViewModel.deleteTagErrorAlert = false
                        }
                    } message: {
                        Text("The tag could not be deleted. Try again later.")
                    }
                }
                .navigationSplitViewColumnWidth(min: proxy.size.width / 3, ideal: proxy.size.width / 3, max: proxy.size.width / 3)
            } detail: {
                if let selected = searchViewModel.selectedLink {
                    NavigationStack {
                        DashboardDetailView(linkOpen: selected)
                    }
                }
                else if horizontalSizeClass == .regular {
                    ContentUnavailableView("Choose a link", systemImage: "link", description: Text("Select a link from the left column"))
                }
                else {
                    EmptyView()
                }
            }
        }
        .environment(searchViewModel)
        .toolbar(horizontalSizeClass == .compact && searchViewModel.preferredColumn == .detail ? .hidden : .visible, for: .tabBar)
    }
}

fileprivate struct SerachContent: View {
    @Environment(SearchViewModel.self) private var searchViewModel
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        let linksSliced = searchViewModel.links.prefix(10)
        let collectionsSliced = searchViewModel.filteredCollections.prefix(10)
        let tagsSliced = searchViewModel.tags.prefix(10)
        
        List {
            if !linksSliced.isEmpty {
                Section {
                    ForEach(linksSliced, id: \.self) { item in
                        LinkItemComponent(item: item, onTaskCompleted: { l, id, action in
                            switch action {
                            case .edit:
                                searchViewModel.handleEditLink(link: l!)
                            case .delete:
                                searchViewModel.handleDeleteLink(linkId: id!)
                            }
                        }, onLinkTap: { link, mode in
                            if let mode = mode {
                                searchViewModel.navigateDetail(link: link, mode: mode)
                            }
                            else if let urlString = link.url, let url = URL(string: urlString) {
                                openURL(url)
                            }
                        }, isSelected: searchViewModel.isSelected(link: item))
                    }
                } header: {
                    HStack {
                        Text("Links")
                        if searchViewModel.links.count > Config.searchViewMoreAmount {
                            Spacer()
                            NavigationLink {
                                LinksSearchResults(searchQuery: searchViewModel.searchQueryValue ?? "")
                            } label: {
                                HStack {
                                    Text("View more")
                                    Spacer()
                                        .frame(width: 8)
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .isDetailLink(false)
                        }
                    }
                }
            }
            if !collectionsSliced.isEmpty {
                Section {
                    ForEach(collectionsSliced, id: \.self) { item in
                        CollectionItemComponent(collection: item, allowSharingOptions: item.ownerId == searchViewModel.loggedUserId, onTaskCompleted: { c, action in
                            if action == .delete {
                                searchViewModel.handleDeleteCollection(collectionId: c.id)
                            }
                        }, onLinkTap: { link, mode in
                            if let mode = mode {
                                searchViewModel.navigateDetail(link: link, mode: mode)
                            }
                            else if let urlString = link.url, let url = URL(string: urlString) {
                                openURL(url)
                            }
                        }, selectedLinkId: searchViewModel.selectedLink?.link.id)
                    }
                } header: {
                    HStack {
                        Text("Collections")
                        if searchViewModel.filteredCollections.count > Config.searchViewMoreAmount {
                            Spacer()
                            NavigationLink {
                                CollectionsSearchResults()
                            } label: {
                                HStack {
                                    Text("View more")
                                    Spacer()
                                        .frame(width: 8)
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .isDetailLink(false)
                        }
                    }
                }
            }
            if !tagsSliced.isEmpty {
                Section {
                    ForEach(tagsSliced, id: \.self) { item in
                        TagItemComponent(tag: item, onDeleteTag: { tag in
                            searchViewModel.handleDeleteTag(tagId: tag.id)
                        }, onEditTag: { tag in
                            searchViewModel.handleEditTag(tag: tag)
                        }, onLinkTap: { link, mode in
                            if let mode = mode {
                                searchViewModel.navigateDetail(link: link, mode: mode)
                            }
                            else if let urlString = link.url, let url = URL(string: urlString) {
                                openURL(url)
                            }
                        }, selectedLinkId: searchViewModel.selectedLink?.link.id)
                    }
                } header: {
                    HStack {
                        Text("Tags")
                        if tagsSliced.count > Config.searchViewMoreAmount {
                            Spacer()
                            NavigationLink {
                                TagsSearchResults(searchQuery: searchViewModel.searchQueryValue ?? "")
                            } label: {
                                HStack {
                                    Text("View more")
                                    Spacer()
                                        .frame(width: 8)
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .isDetailLink(false)
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .transition(.opacity)
    }
}

