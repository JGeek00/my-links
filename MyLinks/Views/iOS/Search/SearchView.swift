import SwiftUI

struct SearchView: View {    
    @State private var searchViewModel: SearchViewModel
    
    init() {
        _searchViewModel = State(initialValue: SearchViewModel())
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
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
                        if horizontalSizeClass == .regular {
                            SearchRegularView()
                        }
                        else {
                            SearchCompactView()
                        }
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
        .environment(searchViewModel)
    }
}

fileprivate struct SearchCompactView: View {
    @Environment(SearchViewModel.self) private var searchViewModel
    
    var body: some View {
        let linksSliced = searchViewModel.links.prefix(10)
        let collectionsSliced = searchViewModel.filteredCollections.prefix(10)
        let tagsSliced = searchViewModel.tags.prefix(10)
        
        List {
            if !linksSliced.isEmpty {
                Section {
                    ForEach(linksSliced, id: \.self) { item in
                        LinkItemComponent(item: item) {l, id, action in
                            switch action {
                            case .edit:
                                searchViewModel.handleEditLink(link: l!)
                            case .delete:
                                searchViewModel.handleDeleteLink(linkId: id!)
                            }
                        }
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
                        }
                    }
                }
            }
            if !collectionsSliced.isEmpty {
                Section {
                    ForEach(collectionsSliced, id: \.self) { item in
                        CollectionItemComponent(collection: item) { c, action in
                            if action == .delete {
                                searchViewModel.handleDeleteCollection(collectionId: c.id)
                            }
                        }
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
                        }
                    }
                }
            }
            if !tagsSliced.isEmpty {
                Section {
                    ForEach(tagsSliced, id: \.self) { item in
                        TagItemComponent(tag: item) { tag in
                            searchViewModel.handleDeleteTag(tagId: tag.id)
                        } onEditTag: { tag in
                            Task { await searchViewModel.loadData(setLoading: false) }
                        }
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
                        }
                    }
                }
            }
        }
        .transition(.opacity)
    }
}

fileprivate struct SearchRegularView: View {
    @Environment(SearchViewModel.self) private var searchViewModel
    
    var body: some View {
        let linksSliced = searchViewModel.links.prefix(10)
        let collectionsSliced = searchViewModel.filteredCollections.prefix(10)
        let tagsSliced = searchViewModel.tags.prefix(10)
        
        ScrollView {
            Group {
                HStack {
                    Text("Links")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    if searchViewModel.links.count > Config.searchViewMoreAmount {
                        Spacer()
                        NavigationLink {
                            LinksSearchResults(searchQuery: searchViewModel.searchQueryValue ?? "")
                        } label: {
                            Text("View all")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 16))
                    }
                }
                .padding(.horizontal, 8)
                LazyVGrid(columns: Config.gridColumns) {
                    ForEach(linksSliced, id: \.self) { item in
                        LinkItemComponent(item: item) { l, id, action in
                            switch action {
                            case .edit:
                                searchViewModel.handleEditLink(link: l!)
                            case .delete:
                                searchViewModel.handleDeleteLink(linkId: id!)
                            }
                        }
                        .padding(8)
                    }
                }
                .padding(.top, -24)
            }
            .padding(16)
            
            Group {
                HStack {
                    Text("Collections")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    if searchViewModel.filteredCollections.count > Config.searchViewMoreAmount {
                        Spacer()
                        NavigationLink {
                            CollectionsSearchResults()
                        } label: {
                            Text("View all")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 16))
                    }
                }
                .padding(.horizontal, 8)
                LazyVGrid(columns: Config.gridColumns) {
                    ForEach(collectionsSliced, id: \.self) { item in
                        CollectionItemComponent(collection: item) { c, action in
                            if action == .delete {
                                searchViewModel.handleDeleteCollection(collectionId: c.id)
                            }
                        }
                        .padding(8)
                    }
                }
                .padding(.top, -24)
            }
            .padding(16)
            
            Group {
                HStack {
                    Text("Tags")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    if searchViewModel.tags.count > Config.searchViewMoreAmount {
                        Spacer()
                        NavigationLink {
                            TagsSearchResults(searchQuery: searchViewModel.searchQueryValue ?? "")
                        } label: {
                            Text("View all")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 16))
                    }
                }
                .padding(.horizontal, 8)
                LazyVGrid(columns: Config.gridColumns) {
                    ForEach(tagsSliced, id: \.self) { item in
                        TagItemComponent(tag: item) { tag in
                            searchViewModel.handleDeleteTag(tagId: tag.id)
                        } onEditTag: { tag in
                            Task { await searchViewModel.loadData(setLoading: false) }
                        }
                        .padding(8)
                    }
                }
                .padding(.top, -24)
            }
            .padding(16)
        }
        .transition(.opacity)
    }
}
