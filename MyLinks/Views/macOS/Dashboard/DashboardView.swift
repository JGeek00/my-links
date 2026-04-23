import SwiftUI

struct DashboardView: View {
    @State private var dashboardViewModel: DashboardViewModel
    
    init() {
        _dashboardViewModel = State(initialValue: DashboardViewModel())
    }
    
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
                            dashboardViewModel.reload()
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                else {
                    if dashboardViewModel.loading {
                        ProgressView()
                    }
                    else if dashboardViewModel.error {
                       
                    }
                    else if let data = dashboardViewModel.data {
                        let pinned = data.links.filter() { $0.pinnedBy != nil && $0.pinnedBy!.isEmpty == false }

                        ScrollView {
                            Section {
                                HStack {
                                    SummaryEntry(icon: "link", label: "Links", value: (dashboardViewModel.collections.map() { $0._count!.links! }).reduce(0, +), color: Color.green, status: dashboardViewModel.loadingCollections == true ? .loading : dashboardViewModel.errorCollections == true ? .error : .loaded)
                                    Divider()
                                    SummaryEntry(icon: "pin.fill", label: "Pinned", value: data.numberOfPinnedLinks, color: Color.orange, status: .loaded)
                                    Divider()
                                    SummaryEntry(icon: "folder.fill", label: "Collections", value: dashboardViewModel.collections.count, color: Color.blue, status: dashboardViewModel.loadingCollections == true ? .loading : dashboardViewModel.errorCollections == true ? .error : .loaded)
                                    Divider()
                                    SummaryEntry(icon: "tag.fill", label: "Tags", value: data.numberOfTags, color: Color.red, status: .loaded)
                                }
                                .padding()
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                            .padding(16)
                            
                            if showPinnedBeforeRecent == true {
                                DashboardPinnedLinks(pinned: pinned)
                                DashboardRecentLinks(links: data.links)
                            }
                            else {
                                DashboardRecentLinks(links: data.links)
                                DashboardPinnedLinks(pinned: pinned)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button {
                        dashboardViewModel.reload()
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
                LinkFormView(mode: Enums.LinkFormItem.url) {
                    linkFormUrlSheet = false
                } onSuccess: { newLink, _ in
                    linkFormUrlSheet = false
                    dashboardViewModel.handleAddLink(link: newLink)
                }
            })
            .sheet(isPresented: $linkFormFileSheet, content: {
                LinkFormView(mode: Enums.LinkFormItem.file) {
                    linkFormFileSheet = false
                } onSuccess: { newLink, _ in
                    linkFormFileSheet = false
                    dashboardViewModel.handleAddLink(link: newLink)
                }
            })
            .sheet(isPresented: $collectionFormSheet, content: {
                CollectionFormView(action: Enums.CollectionFormAction.create) {
                    collectionFormSheet = false
                } onSuccess: { item, _ in
                    collectionFormSheet = false
                    dashboardViewModel.handleAddCollection(collection: item)
                }
            })
            .sheet(isPresented: $tagFormSheet, content: {
                TagFormView(mode: .create) {
                    tagFormSheet = false
                } onSuccess: { _ in
                    tagFormSheet = false
                }
            })
            .onAppear(perform: {
                Task { await dashboardViewModel.loadData() }
            })
        }
        .environment(dashboardViewModel)
    }
}
