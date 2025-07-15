import SwiftUI
import CustomAlert

struct CollectionsView: View {
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    @EnvironmentObject private var apiClientProvider: ApiClientProvider
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var searchText = ""
    @State private var collectionFormSheet = false
    
    var body: some View {
        let notChildCollections = collectionsProvider.data.filter() { $0.parent?.id == nil && $0.parent?.name == nil }
        let searched = searchText != "" ? notChildCollections.filter() { $0.name!.lowercased().contains(searchText.lowercased())} : notChildCollections
        
        Group {
            if horizontalSizeClass == .regular {
                ScrollView {
                    LazyVGrid(columns: Config.gridColumns) {
                        ForEach(searched, id: \.self) { item in
                            CollectionItemComponent(collection: item) {
                                collectionsProvider.deleteCollection(id: item.id!)
                            }
                            .padding(6)
                        }
                    }
                    .padding(.horizontal, 12)
                }
                .overlay(alignment: .center) {
                    if collectionsProvider.data.isEmpty {
                        ContentUnavailableView {
                            Label("No collections added", systemImage: "folder")
                        } description: {
                            Text("Create some collections on Linkwarden to see them here.")
                        }
                    }
                }
                .overlay(alignment: .center) {
                    if searched.isEmpty {
                        ContentUnavailableView {
                            Label("No collections found", systemImage: "folder")
                        } description: {
                            Text("Change the search term to see some collections.")
                        }
                    }
                }
            }
            else {
                List(searched, id: \.self) { item in
                    CollectionItemComponent(collection: item) {
                        collectionsProvider.deleteCollection(id: item.id!)
                    }
                }
                .animation(.default, value: searched)
                .overlay(alignment: .center) {
                    if collectionsProvider.data.isEmpty {
                        ContentUnavailableView {
                            Label("No collections added", systemImage: "folder")
                        } description: {
                            Text("Create some collections on Linkwarden to see them here.")
                        }
                    }
                }
                .overlay(alignment: .center) {
                    if searched.isEmpty && searchText != "" {
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    collectionFormSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .refreshable {
            await collectionsProvider.loadData()
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .overlay(alignment: .center) {
            CollectionsIndicators()
        }
        .customAlert(isPresented: $collectionsProvider.deleting, content: {
            ProgressView()
        })
        .sheet(isPresented: $collectionFormSheet, content: {
            CollectionFormView {
                collectionFormSheet = false
            } onSuccess: { item, action in
                collectionFormSheet = false
            }
            .environmentObject(CollectionFormViewModel())
        })
        .onOpenURL { url in
            if apiClientProvider.instance == nil {
                return
            }
            if url.scheme == DeepLinks.urlScheme && url.host == DeepLinks.newCollection {
                collectionFormSheet = true
            }
        }
        .alert("Error", isPresented: $collectionsProvider.deleteError) {
            Button("Close", role: .cancel) {
                collectionsProvider.deleteError.toggle()
            }
        } message: {
            Text("The collection could not be deleted due to an error.")
        }
    }
}

fileprivate struct CollectionsIndicators: View {
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    
    init() {}
    
    var body: some View {
        if collectionsProvider.loading == true || collectionsProvider.error == true {
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
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .background(Color.listBackground)
        }
    }
}
