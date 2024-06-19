import SwiftUI

struct CollectionView: View {
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    @EnvironmentObject private var collectionFormViewModel: CollectionFormViewModel
    
    init() {}
    
    var body: some View {
        NavigationStack {
            Group {
                if collectionsProvider.loading == true {
                    ProgressView()
                }
                else if collectionsProvider.error == true {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.circle")
                    } description: {
                        Text("An error occured when loading the links data. Check your Internet connection and try again later.")
                        Button {
                            collectionsProvider.loadData(setLoading: true)
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                else {
                    let filtered = collectionsProvider.data?.response?.filter() { $0.name != nil && $0.createdAt != nil } ?? []
                    if !filtered.isEmpty {
                        List(filtered, id: \.self) { item in
                            CollectionItemComponent(collection: item) {
                                
                            }
                        }
                    }
                    else {
                        ContentUnavailableView {
                            Label("No collections added", systemImage: "folder")
                        } description: {
                            Text("Create some collections on Linkwarden to see them here.")
                        }
                    }
                }
            }
            .navigationTitle("Collections")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        collectionFormViewModel.sheetOpen = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                collectionsProvider.loadData()
            }
            .background(Color.listBackground)
        }
    }
}
