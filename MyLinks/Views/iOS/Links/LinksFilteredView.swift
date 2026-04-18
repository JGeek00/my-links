import SwiftUI

struct LinksFilteredView: View {
    var linksFilterdRequest: LinksFilteredRequest
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    
    @StateObject private var linksFilteredViewModel: LinksFilteredViewModel
    
    init(linksFilteredRequest: LinksFilteredRequest) {
        self.linksFilterdRequest = linksFilteredRequest
        _linksFilteredViewModel = StateObject(wrappedValue: LinksFilteredViewModel(input: linksFilteredRequest))
    }
    
    @State private var collectionFormSheet = false
    @State private var linkFormSheet = false
    @State private var fileFormSheet = false

    var body: some View {
        Group {
            if (linksFilteredViewModel.input.mode == .collection || linksFilteredViewModel.input.mode == .tag) && linksFilteredViewModel.input.id == nil  {
                ContentUnavailableView {
                    Label("404", systemImage: "exclamationmark.circle")
                } description: {
                    Text("Requested links not found.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .transition(.opacity)
            }
            else {
                if linksFilteredViewModel.error == true {
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .transition(.opacity)
                }
                else if linksFilteredViewModel.loading == true {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .transition(.opacity)
                }
                else {
                    Group {
                        if horizontalSizeClass == .regular {
                            LinksFilteredRegularView(mode: linksFilterdRequest.mode)
                        }
                        else {
                            LinksFilteredCompactView(mode: linksFilterdRequest.mode)
                        }
                    }
                    .environmentObject(linksFilteredViewModel)
                }
            }
        }
        .background(Color.listBackground)
        .navigationTitle(linksFilteredViewModel.input.name)
        .refreshable {
            await linksFilteredViewModel.loadData()
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
                    if linksFilteredViewModel.input.mode == .collection {
                        Menu {
                            Section {
                                Button {
                                    collectionFormSheet = true
                                } label: {
                                    Label("Create new subcollection", systemImage: "folder")
                                }
                            }
                            Section {
                                Button {
                                    linkFormSheet = true
                                } label: {
                                    Label("Create link on this collection", systemImage: "link")
                                }
                                Button {
                                    fileFormSheet = true
                                } label: {
                                    Label("Upload a file to this collection", systemImage: "doc")
                                }
                            }
                        } label: {
                            Label("Add", systemImage: "plus")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $collectionFormSheet, content: {
            CollectionFormView(parentCollection: linksFilteredViewModel.input.mode == .collection && linksFilteredViewModel.input.id != nil ? collectionsProvider.data.first() { $0.id == linksFilteredViewModel.input.id! } : nil) {
                collectionFormSheet = false
            } onSuccess: { item, action in
                collectionFormSheet = false
            }
        })
        .sheet(isPresented: $linkFormSheet, content: {
            LinkFormView(mode: .url, defaultCollectionId: linksFilterdRequest.id, onClose: {
                linkFormSheet = false
            }, onSuccess: { link, _ in
                linkFormSheet = false
                linksFilteredViewModel.reload()
            })
        })
        .sheet(isPresented: $fileFormSheet, content: {
            LinkFormView(mode: .file, defaultCollectionId: linksFilterdRequest.id, onClose: {
                fileFormSheet = false
            }, onSuccess: { link, _ in
                fileFormSheet = false
                linksFilteredViewModel.reload()
            })
        })
        .searchable(text: $linksFilteredViewModel.searchLinksValue, isPresented: $linksFilteredViewModel.searchLinksPresented, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search")
        .onSubmit(of: .search) {
            if linksFilteredViewModel.loading == false && linksFilteredViewModel.error == false {
                linksFilteredViewModel.searchLinks()
            }
        }
        .onChange(of: linksFilteredViewModel.searchLinksPresented, { oldValue, newValue in
            if oldValue == true && newValue == false {
                linksFilteredViewModel.clearLinksSearch()
            }
        })
        .onAppear(perform: {
            if linksFilteredViewModel.data.isEmpty {
                Task { await linksFilteredViewModel.loadData() }
            }
        })
    }
}

fileprivate struct LinksFilteredRegularView: View {
    var mode: Enums.LinksFilteredMode
    
    init(mode: Enums.LinksFilteredMode) {
        self.mode = mode
    }
    
    @EnvironmentObject private var linksFilteredViewModel: LinksFilteredViewModel
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

fileprivate struct LinksFilteredCompactView: View {
    var mode: Enums.LinksFilteredMode
    
    init(mode: Enums.LinksFilteredMode) {
        self.mode = mode
    }
    
    @EnvironmentObject private var linksFilteredViewModel: LinksFilteredViewModel
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
       
    var body: some View {
        let subCollections = collectionsProvider.data.filter() { $0.parent?.id != nil && linksFilteredViewModel.input.id != nil && $0.parent!.id! == linksFilteredViewModel.input.id! }
        
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
                        let filteredSubCollections = linksFilteredViewModel.searchLinksValue != "" ? subCollections.filter() { $0.name!.lowercased().contains(linksFilteredViewModel.searchLinksValue.lowercased())} : subCollections
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
                                        collectionsProvider.deleteCollection(id: item.id!)
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
                                LinkItemComponent(item: item) { link, action in
                                    linksFilteredViewModel.onTaskCompleted(link: link, action: action)
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
