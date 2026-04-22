import SwiftUI

struct LinksFilteredView: View {
    var linksFilteredRequest: LinksFilteredRequest
        
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var linksFilteredViewModel: LinksFilteredViewModel
    
    init(linksFilteredRequest: LinksFilteredRequest) {
        self.linksFilteredRequest = linksFilteredRequest
        _linksFilteredViewModel = State(initialValue: LinksFilteredViewModel(input: linksFilteredRequest))
    }
    
    @State private var collectionFormSheet = false
    @State private var linkFormSheet = false
    @State private var fileFormSheet = false
    
    var body: some View {
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
            else {
                let subCollections = linksFilteredViewModel.collections.filter() { $0.parent?.id != nil && linksFilteredRequest.id != nil && $0.parent!.id! == linksFilteredRequest.id! }
                ScrollViewReader(content: { scrollView in
                    ScrollView {
                        if linksFilteredRequest.mode == .collection && linksFilteredRequest.id != nil && !subCollections.isEmpty {
                            let filteredCollections = linksFilteredViewModel.searchLinksValue != "" ? subCollections.filter() { $0.name.lowercased().contains(linksFilteredViewModel.searchLinksValue.lowercased()) } : subCollections
                            VStack(alignment: .leading) {
                                if filteredCollections.isEmpty {
                                    ContentUnavailableView {
                                        Label("No subcollections available.", systemImage: "magnifyingglass")
                                    } description: {
                                        Text("Change the inputted search term.")
                                    }
                                    .transition(.opacity)
                                }
                                else {
                                    Text("Collections")
                                        .font(.system(size: 16))
                                        .fontWeight(.semibold)
                                        .padding(.leading, 8)
                                    LazyVGrid(columns: Config.gridColumns) {
                                        ForEach(filteredCollections, id: \.self) { item in
                                            NavigationLink {
                                                LinksFilteredView(linksFilteredRequest: LinksFilteredRequest(name: item.name, mode: .collection, id: item.id))
                                            } label: {
                                                CollectionItemComponent(collection: item) { c, action in
                                                    switch action {
                                                    case .edit:
                                                        linksFilteredViewModel.handleEditCollection(collection: c)
                                                    case .delete:
                                                        linksFilteredViewModel.handleDeleteCollection(collectionId: c.id)
                                                    }
                                                }
                                                .padding(6)
                                            }
                                            .buttonStyle(PlainButtonStyle())
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
                                if linksFilteredRequest.mode == .collection {
                                    Text("Links")
                                        .font(.system(size: 16))
                                        .fontWeight(.semibold)
                                        .padding(.leading, 8)
                                }
                                LazyVGrid(columns: Config.gridColumns) {
                                    ForEach(linksFilteredViewModel.data, id: \.self) { item in
                                        LinkItemComponent(item: item) { l, id, action in
                                            switch action {
                                            case .edit:
                                                linksFilteredViewModel.handleEditLink(link: l!)
                                            case .delete:
                                                linksFilteredViewModel.handleDeleteLink(linkId: id!)
                                            }
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
                                Label("No links added", systemImage: "link")
                            } description: {
                                Text("Save some links on Linkwarden to see them here.")
                            }
                        }
                    }
                })
            }
        }
        .navigationTitle(linksFilteredRequest.name)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                HStack {
                    Button {
                        Task { await linksFilteredViewModel.loadData(setLoading: true) }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
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
                    Picker("Sort", systemImage: "arrow.up.arrow.down", selection: $linksFilteredViewModel.sortingSelected) {
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
                    .disabled(linksFilteredViewModel.loading)
                }
            }
        }
        .refreshable {
            await linksFilteredViewModel.loadData()
        }
        .searchable(text: $linksFilteredViewModel.searchLinksValue, isPresented: $linksFilteredViewModel.searchLinksPresented)
        .onSubmit(of: .search) {
            linksFilteredViewModel.searchLinks()
        }
        .sheet(isPresented: $collectionFormSheet, content: {
            CollectionFormView(collectionId: linksFilteredViewModel.input.mode == .collection ? linksFilteredViewModel.input.id : nil, action: .create) {
                collectionFormSheet = false
            } onSuccess: { item, _ in
                collectionFormSheet = false
                linksFilteredViewModel.handleCollectionCreated(collection: item)
            }
        })
        .sheet(isPresented: $linkFormSheet, content: {
            LinkFormView(mode: .url, defaultCollectionId: linksFilteredRequest.id, onClose: {
                linkFormSheet = false
            }, onSuccess: { link, _ in
                linkFormSheet = false
                linksFilteredViewModel.handleCreatedLink(link: link)
            })
        })
        .sheet(isPresented: $fileFormSheet, content: {
            LinkFormView(mode: .file, defaultCollectionId: linksFilteredRequest.id, onClose: {
                fileFormSheet = false
            }, onSuccess: { link, _ in
                fileFormSheet = false
                linksFilteredViewModel.handleCreatedLink(link: link)
            })
        })
        .onChange(of: linksFilteredViewModel.searchLinksPresented, { oldValue, newValue in
            if oldValue == true && newValue == false {
                linksFilteredViewModel.clearLinksSearch()
            }
        })
        .onChange(of: linksFilteredRequest, initial: true) { _, newValue in
            linksFilteredViewModel = LinksFilteredViewModel(input: newValue)
            Task { await linksFilteredViewModel.loadData(setLoading: true) }
        }
        .environment(linksFilteredViewModel)
    }
}
