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
    
    @State private var linkFormSheet = false
    @State private var collectionFormSheet = false
    
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
                let filtered = linksFilteredViewModel.data.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.url != nil && $0.tags != nil && $0.collection?.id != nil }
                let subCollections = collectionsProvider.data.filter() { $0.parent?.id != nil && input.id != nil && $0.parent!.id! == input.id! }
                if !filtered.isEmpty {
                    ScrollViewReader(content: { scrollView in
                        ScrollView {
                            if input.mode == .collection && input.id != nil && !subCollections.isEmpty {
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
                                    if input.mode == .collection {
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
                                    Label("No links added", systemImage: "link")
                                } description: {
                                    Text("Save some links on Linkwarden to see them here.")
                                }
                            }
                        }
                    })
                }
                else {
                    ContentUnavailableView {
                        Label("No links added", systemImage: "link")
                    } description: {
                        Text("Save some links on Linkwarden to see them here.")
                    }
                }
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
                    Button {
                        collectionFormSheet = true
                    } label: {
                        Image(systemName: "plus")
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
        .searchable(text: $linksFilteredViewModel.searchFieldValue, isPresented: $linksFilteredViewModel.searchPresented)
        .onSubmit(of: .search) {
            linksFilteredViewModel.search()
        }
        .sheet(isPresented: $linkFormSheet, content: {
            LinkFormView() {
                linkFormSheet = false
            } onSuccess: { newLink, action in
                linkFormSheet = false
            }
            .environmentObject(LinkFormViewModel())
        })
        .sheet(isPresented: $collectionFormSheet, content: {
            CollectionFormView(parentCollection: input.mode == .collection && input.id != nil ? collectionsProvider.data.first() { $0.id == input.id! } : nil) {
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
        .onChange(of: input) {
            linksFilteredViewModel.loading = true
            linksFilteredViewModel.input = input
            Task { await linksFilteredViewModel.loadData() }
        }
    }
}
