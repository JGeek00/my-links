import SwiftUI

struct LinksFilteredView: View {
    var linksFilterdRequest: LinksFilteredRequest
        
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var linksFilteredViewModel: LinksFilteredViewModel
    
    init(linksFilteredRequest: LinksFilteredRequest) {
        self.linksFilterdRequest = linksFilteredRequest
        _linksFilteredViewModel = State(initialValue: LinksFilteredViewModel(input: linksFilteredRequest))
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
                    ProgressView("Loading...")
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
            CollectionFormView(parentCollectionId: linksFilteredViewModel.input.mode == .collection ? linksFilteredViewModel.input.id : nil) {
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
                Task { await linksFilteredViewModel.loadData() }
            })
        })
        .sheet(isPresented: $fileFormSheet, content: {
            LinkFormView(mode: .file, defaultCollectionId: linksFilterdRequest.id, onClose: {
                fileFormSheet = false
            }, onSuccess: { link, _ in
                fileFormSheet = false
                Task { await linksFilteredViewModel.loadData() }
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
        .task {
            await linksFilteredViewModel.loadData()
        }
        .environment(linksFilteredViewModel)
    }
}


