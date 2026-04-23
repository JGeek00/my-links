import SwiftUI
import CustomAlert

struct CollectionsView: View {
    @State private var collectionsViewModel: CollectionsViewModel
    
    init() {
       _collectionsViewModel = State(initialValue: CollectionsViewModel())
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var searchText = ""
    @State private var collectionFormSheet = false
    
    var body: some View {
        let notChildCollections = collectionsViewModel.data.filter() { $0.parent?.id == nil && $0.parent?.name == nil }
        let searched = searchText != "" ? notChildCollections.filter() { $0.name.lowercased().contains(searchText.lowercased())} : notChildCollections
        
        Group {
            if collectionsViewModel.loading == true {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if collectionsViewModel.error == true {
                ContentUnavailableView("Error", systemImage: "exclamationmark.circle", description: Text("An error occured when loading the links data. Check your Internet connection and try again later."))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else {
                if horizontalSizeClass == .regular {
                    ScrollView {
                        LazyVGrid(columns: Config.gridColumns) {
                            ForEach(searched, id: \.self) { item in
                                CollectionItemComponent(collection: item) { c, action in
                                    if action == .delete {
                                        collectionsViewModel.handleDeleteCollection(collectionId: c.id)
                                    }
                                }
                                .padding(6)
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    .overlay(alignment: .center) {
                        if collectionsViewModel.data.isEmpty {
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
                        CollectionItemComponent(collection: item) { c, action in
                            if action == .delete {
                                collectionsViewModel.handleDeleteCollection(collectionId: c.id)
                            }
                        }
                    }
                    .animation(.default, value: searched)
                    .overlay(alignment: .center) {
                        if collectionsViewModel.data.isEmpty {
                            ContentUnavailableView {
                                Label("No collections added", systemImage: "folder")
                            } description: {
                                Text("Create some collections on Linkwarden to see them here.")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .overlay(alignment: .center) {
                        if searched.isEmpty && searchText != "" {
                            ContentUnavailableView {
                                Label("No collections found", systemImage: "folder")
                            } description: {
                                Text("Change the search term to see some collections.")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            await collectionsViewModel.loadData()
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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
        .task {
            await collectionsViewModel.loadData()
        }
        .environment(collectionsViewModel)
    }
}
