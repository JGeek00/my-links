import SwiftUI
import CustomAlert

struct CollectionsView: View {
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    @EnvironmentObject private var collectionFormViewModel: CollectionFormViewModel
    
    init() {}
    
    @State private var navigationPath = NavigationPath()
    @State private var searchText = ""
    
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
                    let filtered = collectionsProvider.data.filter() { $0.id != nil && $0.name != nil && $0.createdAt != nil }
                    if filtered.isEmpty {
                        ContentUnavailableView {
                            Label("No collections added", systemImage: "folder")
                        } description: {
                            Text("Create some collections on Linkwarden to see them here.")
                        }
                    }
                    else {
                        let searched = searchText != "" ? filtered.filter() { $0.name!.lowercased().contains(searchText.lowercased())} : filtered
                        if !searched.isEmpty {
                            List(searched, id: \.self) { item in
                                CollectionItemComponent(collection: item) {
                                    navigationPath.append(LinksFilteredRequest(name: item.name!, mode: .collection, id: item.id!))
                                } onDelete: {
                                    collectionsProvider.deleteCollection(id: item.id!)
                                }
                            }
                            .animation(.default, value: searched)
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
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        collectionFormViewModel.reset()
                        collectionFormViewModel.sheetOpen = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                await collectionsProvider.loadData()
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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
