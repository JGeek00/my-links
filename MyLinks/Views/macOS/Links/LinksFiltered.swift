import SwiftUI

struct LinksFilteredView: View {
    var input: LinksFilteredRequest
    
    @StateObject private var linksFilteredViewModel: LinksFilteredViewModel
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    
    init(input: LinksFilteredRequest) {
        self.input = input
        _linksFilteredViewModel = StateObject(wrappedValue: LinksFilteredViewModel(input: input))
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
                let filtered = linksFilteredViewModel.data.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.tags != nil && $0.collection?.id != nil }
                let subCollections = collectionsProvider.data.filter() { $0.parent?.id != nil && input.id != nil && $0.parent!.id! == input.id! }
                ScrollViewReader(content: { scrollView in
                    ScrollView {
                        if input.mode == .collection && input.id != nil && !subCollections.isEmpty {
                            let filteredCollections = linksFilteredViewModel.searchLinksValue != "" ? subCollections.filter() { $0.name!.lowercased().contains(linksFilteredViewModel.searchLinksValue.lowercased()) } : subCollections
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
                                                LinksFilteredView(input: LinksFilteredRequest(name: item.name!, mode: .collection, id: item.id!))
                                            } label: {
                                                CollectionItemComponent(collection: item) {
                                                    collectionsProvider.deleteCollection(id: item.id!)
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
                        if !filtered.isEmpty {
                            VStack(alignment: .leading) {
                                if input.mode == .collection {
                                    Text("Links")
                                        .font(.system(size: 16))
                                        .fontWeight(.semibold)
                                        .padding(.leading, 8)
                                }
                                LazyVGrid(columns: Config.gridColumns) {
                                    ForEach(filtered, id: \.self) { item in
                                        LinkItemComponent(item: item) { link, action in
                                            // TODO: handle actions
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
                                Label("No links added", systemImage: "link")
                            } description: {
                                Text("Save some links on Linkwarden to see them here.")
                            }
                        }
                    }
                })
            }
        }
        .navigationTitle(input.name)
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
            CollectionFormView(parentCollection: input.mode == .collection && input.id != nil ? collectionsProvider.data.first() { $0.id == input.id! } : nil) {
                collectionFormSheet = false
            } onSuccess: { item, action in
                collectionFormSheet = false
            }
            .environmentObject(CollectionFormViewModel())
        })
        .sheet(isPresented: $linkFormSheet, content: {
            LinkFormView(mode: .url, defaultCollectionId: input.id, onClose: {
                linkFormSheet = false
            }, onSuccess: { link, _ in
                linkFormSheet = false
                linksFilteredViewModel.reload()
            })
        })
        .sheet(isPresented: $fileFormSheet, content: {
            LinkFormView(mode: .file, defaultCollectionId: input.id, onClose: {
                fileFormSheet = false
            }, onSuccess: { link, _ in
                fileFormSheet = false
                linksFilteredViewModel.reload()
            })
        })
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
        .onChange(of: input) {
            linksFilteredViewModel.loading = true
            linksFilteredViewModel.input = input
            Task { await linksFilteredViewModel.loadData() }
        }
    }
}
