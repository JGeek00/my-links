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
            CollectionFormView(collectionId: linksFilteredViewModel.input.mode == .collection ? linksFilteredViewModel.input.id : nil, action: .create) {
                collectionFormSheet = false
            } onSuccess: { item, _ in
                collectionFormSheet = false
                linksFilteredViewModel.handleCollectionCreated(collection: item)
            }
        })
        .sheet(isPresented: $linkFormSheet, content: {
            LinkFormView(mode: .url, defaultCollectionId: linksFilterdRequest.id, onClose: {
                linkFormSheet = false
            }, onSuccess: { link, _ in
                linkFormSheet = false
                linksFilteredViewModel.handleCreatedLink(link: link)
            })
        })
        .sheet(isPresented: $fileFormSheet, content: {
            LinkFormView(mode: .file, defaultCollectionId: linksFilterdRequest.id, onClose: {
                fileFormSheet = false
            }, onSuccess: { link, _ in
                fileFormSheet = false
                linksFilteredViewModel.handleCreatedLink(link: link)
            })
        })
        .alert("Error", isPresented: $linksFilteredViewModel.deleteLinkErrorAlert) {
            Button("OK") {
                linksFilteredViewModel.deleteLinkErrorAlert = false
            }
        } message: {
            Text("An error occured when deleting the link. Try again later.")
        }
        .alert("Error", isPresented: $linksFilteredViewModel.deleteCollectionErrorAlert) {
            Button("OK") {
                linksFilteredViewModel.deleteCollectionErrorAlert = false
            }
        } message: {
            Text("An error occured when deleting the collection. Try again later.")
        }
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


