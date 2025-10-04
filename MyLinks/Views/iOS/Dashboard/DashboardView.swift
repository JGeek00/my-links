import SwiftUI
import CustomAlert

struct DashboardView: View {
    
    init() {}
    
    @EnvironmentObject private var dashboardViewModel: DashboardViewModel
    @EnvironmentObject private var tagsProvider: TagsProvider
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    @EnvironmentObject private var apiClientProvider: ApiClientProvider
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var navigationPath = NavigationPath()
    @State private var linkFormUrlSheet = false
    @State private var linkFormFileSheet = false
    @State private var collectionFormSheet = false
    
    var body: some View {
        NavigationStack(path: $dashboardViewModel.path) {
            Group {
                if horizontalSizeClass == .regular {
                    DashboardRegularView()
                }
                else {
                    DashboardCompactView()
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
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
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .background(Color.listBackground)
            .navigationDestination(for: LinksFilteredRequest.self) { value in
                LinksFilteredView(linksFilteredRequest: value)
            }
            .sheet(isPresented: $linkFormUrlSheet, content: {
                LinkFormView(mode: .url) {
                    linkFormUrlSheet = false
                } onSuccess: { newLink, action in
                    linkFormUrlSheet = false
                }
                .environmentObject(LinkFormViewModel())
            })
            .sheet(isPresented: $linkFormFileSheet, content: {
                LinkFormView(mode: .file) {
                    linkFormFileSheet = false
                } onSuccess: { newLink, action in
                    linkFormFileSheet = false
                }
                .environmentObject(LinkFormViewModel())
            })
            .onOpenURL { url in
                if apiClientProvider.instance == nil {
                    return
                }
                if url.scheme == DeepLinks.urlScheme && url.host == DeepLinks.newLink {
                    linkFormUrlSheet = true
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
        }
        .onAppear(perform: {
            if dashboardViewModel.data.isEmpty {
                Task { await dashboardViewModel.loadData() }
            }
        })
    }
}

fileprivate struct DashboardRegularView: View {
    @EnvironmentObject private var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        let filtered = dashboardViewModel.data.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.tags != nil && $0.collection?.id != nil }
        let pinned = filtered.filter() { $0.pinnedBy != nil && $0.pinnedBy!.isEmpty == false }
        ScrollView {
            Header(dashboardData: dashboardViewModel.data)
            if !filtered.isEmpty {
                VStack {
                    HStack {
                        Text("Recent")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                        Spacer()
                        ViewAllButton {
                            dashboardViewModel.navigateRecent()
                        }
                    }
                    .padding(.horizontal, 8)
                    Spacer()
                        .frame(height: 16)
                    LazyVGrid(columns: Config.gridColumns) {
                        ForEach(filtered.uniqued(), id: \.self) { item in
                            LinkItemComponent(item: item) { link, action in
                                dashboardViewModel.reload()
                            }
                            .padding(6)
                        }
                    }
                }
                .padding(8)
            }
            if !pinned.isEmpty {
                VStack {
                    HStack {
                        Text("Pinned")
                            .font(.system(size: 16))
                            .fontWeight(.semibold)
                        Spacer()
                        ViewAllButton {
                            dashboardViewModel.navigatePinned()
                        }
                    }
                    .padding(.horizontal, 8)
                    Spacer()
                        .frame(height: 16)
                    LazyVGrid(columns: Config.gridColumns) {
                        ForEach(pinned.uniqued(), id: \.self) { item in
                            LinkItemComponent(item: item) { link, action in
                                dashboardViewModel.reload()
                            }
                            .padding(6)
                        }
                    }
                }
                .padding(8)
            }
        }
        .refreshable {
            await dashboardViewModel.loadData()
        }
        .overlay(alignment: .center) {
            DashboardIndicators()
        }
    }
}

fileprivate struct DashboardCompactView: View {
    @EnvironmentObject private var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        let filtered = dashboardViewModel.data.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.tags != nil && $0.collection?.id != nil }
        let pinned = filtered.filter() { $0.pinnedBy != nil && $0.pinnedBy!.isEmpty == false }
        List {
            Section {} header: {
                Header(dashboardData: dashboardViewModel.data)
            }
            if !filtered.isEmpty {
                Section {
                    ForEach(filtered.uniqued(), id: \.self) { item in
                        LinkItemComponent(item: item) { link, action in
                            dashboardViewModel.reload()
                        }
                    }
                    .overlay(alignment: .center) {
                        if filtered.isEmpty {
                            ContentUnavailableView {
                                Label("No links added", systemImage: "link")
                            } description: {
                                Text("Save some links on Linkwarden to see them here.")
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                } header: {
                    HStack {
                        Text("Recent")
                        Spacer()
                        ViewAllButton {
                            dashboardViewModel.navigateRecent()
                        }
                    }
                }
            }
            if !pinned.isEmpty {
                Section {
                    ForEach(pinned.uniqued(), id: \.self) { item in
                        LinkItemComponent(item: item) { link, action in
                            dashboardViewModel.reload()
                        }
                    }
                } header: {
                    HStack {
                        Text("Pinned")
                        Spacer()
                        ViewAllButton {
                            dashboardViewModel.navigatePinned()
                        }
                    }
                }
            }
        }
        .animation(.default, value: dashboardViewModel.data)
        .refreshable {
            await dashboardViewModel.loadData()
        }
        .overlay(alignment: .center) {
            DashboardIndicators()
                .transition(.opacity)
        }
    }
}
