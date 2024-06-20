import SwiftUI
import CustomAlert

struct CollectionsView: View {
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    @EnvironmentObject private var collectionFormViewModel: CollectionFormViewModel
    
    init() {}
    
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                    let filtered = collectionsProvider.data?.response?.filter() { $0.id != nil && $0.name != nil && $0.createdAt != nil } ?? []
                    if !filtered.isEmpty {
                        List(filtered, id: \.self) { item in
                            CollectionItemComponent(collection: item) {
                                navigationPath.append(LinksFilteredRequest(name: item.name!, mode: .collection, id: item.id!))
                            } onDelete: {
                                collectionsProvider.deleteCollection(id: item.id!)
                            }
                        }
                        .animation(.default, value: filtered)
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
                        collectionFormViewModel.editingId = nil
                        collectionFormViewModel.sheetOpen = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                await collectionsProvider.loadData()
            }
            .background(Color.listBackground)
            .customAlert(isPresented: $collectionsProvider.deleting, content: {
                ProgressView()
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
