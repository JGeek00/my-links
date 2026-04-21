import SwiftUI

struct CollectionsView: View {
    @State private var collectionsViewModel: CollectionsViewModel
    
    init() {
        _collectionsViewModel = State(initialValue: CollectionsViewModel())
    }
    
    @State private var searchText = ""
    @State private var collectionFormSheet = false
    
    var body: some View {
        NavigationStack {
            Group {
                if collectionsViewModel.loading == true {
                    Group {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if collectionsViewModel.error == true {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.circle")
                    } description: {
                        Text("An error occured when loading the links data. Check your Internet connection and try again later.")
                        Button {
                            Task { await collectionsViewModel.loadData(setLoading: true) }
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                else {
                    if collectionsViewModel.data.isEmpty {
                        ContentUnavailableView {
                            Label("No collections added", systemImage: "folder")
                        } description: {
                            Text("Create some collections on Linkwarden to see them here.")
                        }
                    }
                    else {
                        let notChildCollections = collectionsViewModel.data.filter() { $0.parent?.id == nil && $0.parent?.name == nil }
                        let searched = searchText != "" ? notChildCollections.filter() { $0.name.lowercased().contains(searchText.lowercased())} : notChildCollections
                        if !searched.isEmpty {
                            ScrollView {
                                LazyVGrid(columns: Config.gridColumns) {
                                    ForEach(searched, id: \.self) { item in
                                        NavigationLink {
                                            LinksFilteredView(linksFilteredRequest: LinksFilteredRequest(name: item.name, mode: .collection, id: item.id))
                                        } label: {
                                            CollectionItemComponent(collection: item) { c, action in
                                                switch action {
                                                case .edit:
                                                    collectionsViewModel.handleEditCollection(collection: c)
                                                case .delete:
                                                    collectionsViewModel.handleDeleteCollection(collectionId: c.id)
                                                }
                                            }
                                            .padding(6)
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding(12)
                            }
                        }
                        else {
                            ContentUnavailableView {
                                Label("No collections found", systemImage: "folder")
                            } description: {
                                Text("Change the search term to see some collections.")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Collections")
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    HStack {
                        Button {
                            Task { await collectionsViewModel.loadData(setLoading: true) }
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                        }
                        Button {
                            collectionFormSheet = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .sheet(isPresented: $collectionFormSheet, content: {
                CollectionFormView(action: .create) {
                    collectionFormSheet = false
                } onSuccess: { item, _ in
                    collectionFormSheet = false
                    collectionsViewModel.handleCollectionCreated(collection: item)
                }
            })
            .alert("Error", isPresented: $collectionsViewModel.deleteError) {
                Button("Close", role: .cancel) {
                    collectionsViewModel.deleteError.toggle()
                }
            } message: {
                Text("The collection could not be deleted due to an error.")
            }
        }
        .task {
            await collectionsViewModel.loadData()
        }
        .environment(collectionsViewModel)
    }
}
