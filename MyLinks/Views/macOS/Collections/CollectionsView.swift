import SwiftUI

struct CollectionsView: View {
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
        
    init() {}
    
    @State private var searchText = ""
    @State private var collectionFormSheet = false
    
    var body: some View {
        NavigationStack(path: $collectionsProvider.navigationPath) {
            Group {
                if collectionsProvider.loading == true {
                    Group {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if collectionsProvider.error == true {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.circle")
                    } description: {
                        Text("An error occured when loading the links data. Check your Internet connection and try again later.")
                        Button {
                            Task { await collectionsProvider.loadData(setLoading: true) }
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                else {
                    if collectionsProvider.data.isEmpty {
                        ContentUnavailableView {
                            Label("No collections added", systemImage: "folder")
                        } description: {
                            Text("Create some collections on Linkwarden to see them here.")
                        }
                    }
                    else {
                        let notChildCollections = collectionsProvider.data.filter() { $0.parent?.id == nil && $0.parent?.name == nil }
                        let searched = searchText != "" ? notChildCollections.filter() { $0.name!.lowercased().contains(searchText.lowercased())} : notChildCollections
                        if !searched.isEmpty {
                            ScrollView {
                                LazyVGrid(columns: Config.gridColumns) {
                                    ForEach(searched, id: \.self) { item in
                                        CollectionItemComponent(collection: item) {
                                            collectionsProvider.navigationPath.append(LinksFilteredRequest(name: item.name!, mode: .collection, id: item.id!))
                                        } onDelete: {
                                            collectionsProvider.deleteCollection(id: item.id!)
                                        }
                                        .padding(6)
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
            .refreshable {
                await collectionsProvider.loadData()
            }
            .searchable(text: $searchText)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        collectionFormSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $collectionFormSheet, content: {
                CollectionFormView {
                    collectionFormSheet = false
                } onSuccess: { item, action in
                    collectionFormSheet = false
                }
                .environmentObject(CollectionFormViewModel())
            })
            .alert("Error", isPresented: $collectionsProvider.deleteError) {
                Button("Close", role: .cancel) {
                    collectionsProvider.deleteError.toggle()
                }
            } message: {
                Text("The collection could not be deleted due to an error.")
            }
            .navigationDestination(for: LinksFilteredRequest.self) { value in
                LinksFilteredView(input: value)
            }
        }
    }
}
