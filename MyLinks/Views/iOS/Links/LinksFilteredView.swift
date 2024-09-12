import SwiftUI

struct LinksFilteredView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @EnvironmentObject private var linksFilteredViewModel: LinksFilteredViewModel
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    
    init() {}
    
    @State private var collectionFormSheet = false
    
    var body: some View {
        Group {
            if horizontalSizeClass == .regular {
                LinksFilteredRegularView()
            }
            else {
                LinksFilteredCompactView()
            }
        }
        .navigationTitle(linksFilteredViewModel.input.name)
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await linksFilteredViewModel.loadData()
        }
        .searchable(text: $linksFilteredViewModel.searchFieldValue, isPresented: $linksFilteredViewModel.searchPresented, placement: .navigationBarDrawer(displayMode: .always))
        .onSubmit(of: .search) {
            linksFilteredViewModel.search()
        }
        .overlay(alignment: .center) {
            LinksFilteredIndicators()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack {
                    Menu {
                        Picker("", selection: $linksFilteredViewModel.sortingSelected) {
                            Text("Date (newest first)")
                                .tag(Enums.SortingOptions.dateNewestFirst)
                            Text("Date (oldest first)")
                                .tag(Enums.SortingOptions.dateOldestFirst)
                            Text("Name (A-Z)")
                                .tag(Enums.SortingOptions.nameAZ)
                            Text("Name (Z-A)")
                                .tag(Enums.SortingOptions.nameZA)
                            Text("Description (A-Z)")
                                .tag(Enums.SortingOptions.descriptionAZ)
                            Text("Description (Z-A)")
                                .tag(Enums.SortingOptions.descriptionZA)
                        }
                        .onChange(of: linksFilteredViewModel.sortingSelected, initial: false) {
                            Task { await linksFilteredViewModel.loadData(setLoading: true) }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                    }
                    .disabled(linksFilteredViewModel.loading)
                    if linksFilteredViewModel.input.mode == .collection && linksFilteredViewModel.input.id != nil {
                        Button {
                            collectionFormSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
        }
        .background(Color.listBackground)
        .sheet(isPresented: $collectionFormSheet, content: {
            CollectionFormView(parentCollection: linksFilteredViewModel.input.mode == .collection && linksFilteredViewModel.input.id != nil ? collectionsProvider.data.first() { $0.id == linksFilteredViewModel.input.id! } : nil) {
                collectionFormSheet = false
            } onSuccess: { item, action in
                collectionFormSheet = false
            }
            .environmentObject(CollectionFormViewModel())
        })
        .onChange(of: linksFilteredViewModel.searchPresented, { oldValue, newValue in
            if oldValue == true && newValue == false {
                linksFilteredViewModel.clearSearch()
            }
        })
        .onAppear(perform: {
            if linksFilteredViewModel.data.isEmpty {
                Task { await linksFilteredViewModel.loadData() }
            }
        })
    }
}

private struct LinksFilteredRegularView: View {
    @EnvironmentObject private var linksFilteredViewModel: LinksFilteredViewModel
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    
    init() {}
    
    var body: some View {
        let filtered = linksFilteredViewModel.data.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.tags != nil && $0.collection?.id != nil }
        let subCollections = collectionsProvider.data.filter() { $0.parent?.id != nil && linksFilteredViewModel.input.id != nil && $0.parent!.id! == linksFilteredViewModel.input.id! }
        ScrollViewReader(content: { scrollView in
            ScrollView {
                if linksFilteredViewModel.input.mode == .collection && linksFilteredViewModel.input.id != nil && !subCollections.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Collections")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                            .padding(.leading, 8)
                        LazyVGrid(columns: Config.gridColumns) {
                            ForEach(subCollections, id: \.self) { item in
                                CollectionItemComponent(collection: item) {
                                    collectionsProvider.navigationPath.append(LinksFilteredRequest(name: item.name!, mode: .collection, id: item.id!))
                                } onDelete: {
                                    collectionsProvider.deleteCollection(id: item.id!)
                                }
                                .padding(6)
                            }
                        }
                    }
                    .padding(.top, 16)
                    .padding(.horizontal, 14)
                }
                if !filtered.isEmpty {
                    VStack(alignment: .leading) {
                        if linksFilteredViewModel.input.mode == .collection {
                            Text("Links")
                                .font(.system(size: 16))
                                .fontWeight(.semibold)
                                .padding(.leading, 8)
                        }
                        LazyVGrid(columns: Config.gridColumns) {
                            ForEach(filtered, id: \.self) { item in
                                LinkItemComponent(item: item) { link, action in
                                    linksFilteredViewModel.onTaskCompleted(link: link, action: action)
                                }
                                .onAppear {
                                    if item == filtered.last {
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
                        Label("No links added to this collection", systemImage: "link")
                    } description: {
                        Text("Add some links to this collection to see them here.")
                    }
                }
            }
        })
    }
}

private struct LinksFilteredCompactView: View {
    @EnvironmentObject private var linksFilteredViewModel: LinksFilteredViewModel
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    
    init() {}
   
    var body: some View {
        let filtered = linksFilteredViewModel.data.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.tags != nil && $0.collection?.id != nil }
        let subCollections = collectionsProvider.data.filter() { $0.parent?.id != nil && linksFilteredViewModel.input.id != nil && $0.parent!.id! == linksFilteredViewModel.input.id! }
        
        if filtered.isEmpty && subCollections.isEmpty {
            // Show when no links and no subcategories
            ContentUnavailableView {
                Label("No links added to this collection", systemImage: "link")
            } description: {
                Text("Add some links to this collection to see them here.")
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
        }
        else {
            ScrollViewReader { scrollView in
                List {
                    if linksFilteredViewModel.input.mode == .collection && linksFilteredViewModel.input.id != nil && !subCollections.isEmpty {
                        Section("Collections") {
                            ForEach(subCollections, id: \.self) { item in
                                CollectionItemComponent(collection: item) {
                                    collectionsProvider.navigationPath.append(LinksFilteredRequest(name: item.name!, mode: .collection, id: item.id!))
                                } onDelete: {
                                    collectionsProvider.deleteCollection(id: item.id!)
                                }
                            }
                        }
                    }
                    if filtered.isEmpty {
                        // Show when subcategories but no links
                        ContentUnavailableView {
                            Label("No links added to this collection", systemImage: "link")
                        } description: {
                            Text("Add some links to this collection to see them here.")
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    else {
                        Section("Links") {
                            ForEach(filtered, id: \.self) { item in
                                LinkItemComponent(item: item) { link, action in
                                    linksFilteredViewModel.onTaskCompleted(link: link, action: action)
                                }
                                .onAppear {
                                    if item == filtered.last {
                                        linksFilteredViewModel.loadMore()
                                    }
                                }
                            }
                        }
                    }
                }
                .animation(.default, value: filtered)
                .animation(.default, value: subCollections)
            }
        }
    }
}

private struct LinksFilteredIndicators: View {
    @EnvironmentObject private var linksFilteredViewModel: LinksFilteredViewModel
    
    init() {}
    
    var body: some View {
        if (linksFilteredViewModel.input.mode == .collection || linksFilteredViewModel.input.mode == .tag) && linksFilteredViewModel.input.id == nil {
            ContentUnavailableView {
                Label("404", systemImage: "exclamationmark.circle")
            } description: {
                Text("Requested links not found.")
            }
        }
        else if linksFilteredViewModel.loading == true || linksFilteredViewModel.error == true {
            Group {
                if linksFilteredViewModel.loading == true {
                    Group {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if linksFilteredViewModel.error == true {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.circle")
                    } description: {
                        Text("An error occured when loading the links data. Check your Internet connection and try again later.")
                        Button {
                            Task { await linksFilteredViewModel.loadData(setLoading: true) }
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
