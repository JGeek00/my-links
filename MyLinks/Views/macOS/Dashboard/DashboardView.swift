import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var dashboardViewModel: DashboardViewModel
    @EnvironmentObject private var tagsProvider: TagsProvider
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    
    @State private var linkFormUrlSheet = false
    @State private var linkFormFileSheet = false
    @State private var collectionFormSheet = false
    @State private var tagFormSheet = false
    
    @AppStorage(StorageKeys.showPinnedBeforeRecent, store: UserDefaults.shared) private var showPinnedBeforeRecent: Bool = true

    var body: some View {
        NavigationStack {
            Group {
                if dashboardViewModel.loading == true {
                    Group {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if dashboardViewModel.error == true {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.circle")
                    } description: {
                        Text("An error occured when loading the dashboard data. Check your Internet connection and try again later.")
                        Button {
                            Task { await dashboardViewModel.reloadAll() }
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                else {
                    let filtered = dashboardViewModel.data.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.tags != nil && $0.collection?.id != nil }
                    let pinned = filtered.filter() { $0.pinnedBy != nil && $0.pinnedBy!.isEmpty == false }
                    
                    ScrollView {
                        Section {
                            HStack {
                                SummaryEntry(icon: "link", label: "Links", value: (collectionsProvider.data.map() { $0._count!.links! }).reduce(0, +), color: Color.green, status: collectionsProvider.loading == true ? .loading : collectionsProvider.error == true ? .error : .loaded)
                                Divider()
                                SummaryEntry(icon: "folder.fill", label: "Collections", value: collectionsProvider.data.count, color: Color.blue, status: collectionsProvider.loading == true ? .loading : collectionsProvider.error == true ? .error : .loaded)
                                Divider()
                                SummaryEntry(icon: "tag.fill", label: "Tags", value: tagsProvider.data.count, color: Color.red, status: tagsProvider.loading == true ? .loading : tagsProvider.error == true ? .error : .loaded)
                            }
                            .padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .padding(16)
                        
                        if showPinnedBeforeRecent == true {
                            DashboardPinnedLinks()
                            DashboardRecentLinks()
                        }
                        else {
                            DashboardRecentLinks()
                            DashboardPinnedLinks()
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        Task { await dashboardViewModel.reloadAll(setLoading: true) }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                }
                ToolbarItem(placement: .automatic) {
                    Menu {
                        Section {
                            Button {
                                linkFormUrlSheet.toggle()
                            } label: {
                                Label("New link", systemImage: "link")
                            }
                            Button {
                                linkFormFileSheet.toggle()
                            } label: {
                                Label("Upload file", systemImage: "doc")
                            }
                        }
                        Button {
                            collectionFormSheet = true
                        } label: {
                            Label("New collection", systemImage: "folder")
                        }
                        Button {
                            tagFormSheet = true
                        } label: {
                            Label("New tag", systemImage: "tag")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $linkFormUrlSheet, content: {
                LinkFormView(mode: .url) {
                    linkFormUrlSheet = false
                } onSuccess: { newLink, action in
                    linkFormUrlSheet = false
                }
            })
            .sheet(isPresented: $linkFormFileSheet, content: {
                LinkFormView(mode: .file) {
                    linkFormFileSheet = false
                } onSuccess: { newLink, action in
                    linkFormFileSheet = false
                }
            })
            .sheet(isPresented: $collectionFormSheet, content: {
                CollectionFormView() {
                    collectionFormSheet = false
                } onSuccess: { item, action in
                    collectionFormSheet = false
                }
                .environmentObject(CollectionFormViewModel())
            })
            .sheet(isPresented: $tagFormSheet, content: {
                TagFormView {
                    tagFormSheet = false
                }
            })
            .onAppear(perform: {
                Task { await dashboardViewModel.loadData() }
            })
        }
    }
}
