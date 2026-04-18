import SwiftUI

struct SearchView: View {
    @EnvironmentObject private var searchViewModel: SearchViewModel
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
        
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        NavigationStack {
            Group {
                if searchViewModel.searchQueryValue == nil {
                    ContentUnavailableView("Insert search term", systemImage: "magnifyingglass", description: Text("Input a search term to search links, categories and tags"))
                        .transition(.opacity)
                }
                else {
                    if searchViewModel.loading == true {
                        ProgressView()
                            .transition(.opacity)
                    }
                    if searchViewModel.error == true {
                        ContentUnavailableView {
                            Label("Error", systemImage: "exclamationmark.circle")
                        } description: {
                            Text("An error occured when loading the dashboard data. Check your Internet connection and try again later.")
                            Button {
                                searchViewModel.reload()
                            } label: {
                                Label("Retry", systemImage: "arrow.counterclockwise")
                            }
                        }
                        .transition(.opacity)
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
        }
    }
}

fileprivate struct SearchCompactView: View {
    @EnvironmentObject private var searchViewModel: SearchViewModel
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    
    var body: some View {
        let linksSliced = searchViewModel.links.prefix(10)
        let collectionsSliced = collectionsProvider.data.filter({ $0.name!.lowercased().contains((searchViewModel.searchQueryValue?.lowercased()) ?? "") }).prefix(10)
        // let tagsSliced = tagsProvider.data.filter({ $0.name.lowercased().contains((searchViewModel.searchQueryValue?.lowercased()) ?? "") }).prefix(10)
        
        List {
            if !linksSliced.isEmpty {
                Section {
                    ForEach(linksSliced, id: \.self) { item in
                        LinkItemComponent(item: item) { _, _ in }
                    }
                } header: {
                    HStack {
                        Text("Links")
                        if searchViewModel.links.count > 10 {
                            Spacer()
                            NavigationLink {
                                LinksSearchResults()
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
                        CollectionItemComponent(collection: item) {
                            collectionsProvider.deleteCollection(id: item.id!)
                        }
                    }
                } header: {
                    HStack {
                        Text("Collections")
                        if collectionsProvider.data.count > 10 {
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
//            if !tagsSliced.isEmpty {
//                Section {
//                    ForEach(tagsSliced, id: \.self) { item in
//                        TagItemComponent(tag: item)
//                    }
//                } header: {
//                    HStack {
//                        Text("Tags")
//                        if tagsProvider.data.count > 10 {
//                            Spacer()
//                            NavigationLink {
//                                TagsSearchResults()
//                            } label: {
//                                HStack {
//                                    Text("View more")
//                                    Spacer()
//                                        .frame(width: 8)
//                                    Image(systemName: "arrow.right")
//                                }
//                            }
//                        }
//                    }
//                }
//            }
        }
        .transition(.opacity)
    }
}

fileprivate struct SearchRegularView: View {
    @EnvironmentObject private var searchViewModel: SearchViewModel
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    
    var body: some View {
        let linksSliced = searchViewModel.links.prefix(10)
        let collectionsSliced = collectionsProvider.data.filter({ $0.name!.lowercased().contains((searchViewModel.searchQueryValue?.lowercased()) ?? "") }).prefix(10)
        // let tagsSliced = tagsProvider.data.filter({ $0.name.lowercased().contains((searchViewModel.searchQueryValue?.lowercased()) ?? "") }).prefix(10)
        
        ScrollView {
            Group {
                HStack {
                    Text("Links")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    Spacer()
                    NavigationLink {
                        LinksSearchResults()
                    } label: {
                        Text("View all")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 16))
                }
                .padding(.horizontal, 8)
                LazyVGrid(columns: Config.gridColumns) {
                    ForEach(linksSliced, id: \.self) { item in
                        LinkItemComponent(item: item) { _, _ in }
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
                    Spacer()
                    NavigationLink {
                        CollectionsSearchResults()
                    } label: {
                        Text("View all")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 16))
                }
                .padding(.horizontal, 8)
                LazyVGrid(columns: Config.gridColumns) {
                    ForEach(collectionsSliced, id: \.self) { item in
                        CollectionItemComponent(collection: item) {
                            collectionsProvider.deleteCollection(id: item.id!)
                        }
                        .padding(8)
                    }
                }
                .padding(.top, -24)
            }
            .padding(16)
            
//            Group {
//                HStack {
//                    Text("Tags")
//                        .font(.system(size: 16))
//                        .fontWeight(.semibold)
//                    Spacer()
//                    NavigationLink {
//                        TagsSearchResults()
//                    } label: {
//                        Text("View all")
//                        Image(systemName: "chevron.right")
//                    }
//                    .font(.system(size: 16))
//                }
//                .padding(.horizontal, 8)
//                LazyVGrid(columns: Config.gridColumns) {
//                    ForEach(tagsSliced, id: \.self) { item in
//                        TagItemComponent(tag: item)
//                            .padding(8)
//                    }
//                }
//                .padding(.top, -24)
//            }
//            .padding(16)
        }
        .transition(.opacity)
    }
}
