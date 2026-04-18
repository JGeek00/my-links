import SwiftUI
import CustomAlert

struct DashboardView: View {
    
    init() {}
    
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    @EnvironmentObject private var apiClientProvider: ApiClientProvider
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var dashboardViewModel = DashboardViewModel()
    
    @State private var navigationPath = NavigationPath()
    @State private var linkFormUrlSheet = false
    @State private var linkFormFileSheet = false
    @State private var collectionFormSheet = false
    
    var body: some View {
        @Bindable var dashboardViewModel = dashboardViewModel
        NavigationStack(path: $dashboardViewModel.path) {
            Group {
                switch dashboardViewModel.state {
                case .loading:
                    ProgressView("Loading...")
                case .success(let data):
                    if horizontalSizeClass == .regular {
                        DashboardRegularView(data: data)
                    }
                    else {
                        DashboardCompactView(data: data)
                    }
                case .failure:
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
            }
            .transition(.opacity)
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
            .navigationDestination(for: LinksFilteredRequest.self) { value in
                LinksFilteredView(linksFilteredRequest: value)
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
        .task {
            await dashboardViewModel.loadData()
        }
        .environment(dashboardViewModel)
    }
}

struct DashboardRegularView: View {
    let data: DashboardResponse_Data
    
    init(data: DashboardResponse_Data) {
        self.data = data
    }
    
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    
    @AppStorage(StorageKeys.showPinnedBeforeRecent, store: UserDefaults.shared) private var showPinnedBeforeRecent: Bool = false
    
    var body: some View {
        ScrollView {
            Header(dashboardData: data)
            if showPinnedBeforeRecent == true {
                DashboardRegularViewPinned(data: data)
                DashboardRegularViewRecent(data: data)
            }
            else {
                DashboardRegularViewRecent(data: data)
                DashboardRegularViewPinned(data: data)
            }
        }
        .refreshable {
            await dashboardViewModel.loadData()
        }
    }
}

fileprivate struct DashboardCompactView: View {
    let data: DashboardResponse_Data
    
    init(data: DashboardResponse_Data) {
        self.data = data
    }
    
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    
    @AppStorage(StorageKeys.showPinnedBeforeRecent, store: UserDefaults.shared) private var showPinnedBeforeRecent: Bool = false
    
    var body: some View {
        List {
            Section {} header: {
                Header(dashboardData: data)
            }
            if showPinnedBeforeRecent == true {
                DashboardCompactViewPinned(data: data)
                DashboardCompactViewRecent(data: data)
            }
            else {
                DashboardCompactViewRecent(data: data)
                DashboardCompactViewPinned(data: data)
            }
        }
        .animation(.default, value: data)
        .refreshable {
            await dashboardViewModel.loadData()
        }
    }
}
