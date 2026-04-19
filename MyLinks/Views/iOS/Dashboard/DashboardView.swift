import SwiftUI
import CustomAlert

struct DashboardView: View {
    @State private var dashboardViewModel: DashboardViewModel
    
    init() {
        _dashboardViewModel = State(initialValue: DashboardViewModel())
    }
        
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
        
    @State private var navigationPath = NavigationPath()
    @State private var linkFormUrlSheet = false
    @State private var linkFormFileSheet = false
    @State private var collectionFormSheet = false
    
    var body: some View {
        @Bindable var dashboardViewModel = dashboardViewModel
        NavigationStack(path: $dashboardViewModel.path) {
            Group {
                if dashboardViewModel.loading == true {
                    ProgressView("Loading...")
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
                else if let data = dashboardViewModel.data  {
                    if horizontalSizeClass == .regular {
                        DashboardRegularView(data: data)
                    }
                    else {
                        DashboardCompactView(data: data)
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
                } onSuccess: { newLink, _ in
                    linkFormUrlSheet = false
                    dashboardViewModel.handleAddLink(link: newLink)
                }
            })
            .sheet(isPresented: $linkFormFileSheet, content: {
                LinkFormView(mode: .file) {
                    linkFormFileSheet = false
                } onSuccess: { newLink, _ in
                    linkFormFileSheet = false
                    dashboardViewModel.handleAddLink(link: newLink)
                }
            })
            .sheet(isPresented: $collectionFormSheet, content: {
                CollectionFormView(action: .create) {
                    collectionFormSheet = false
                } onSuccess: { item, _ in
                    collectionFormSheet = false
                    dashboardViewModel.handleAddCollection(collection: item)
                }
            })
            .alert("Error", isPresented: $dashboardViewModel.deleteLinkErrorAlert) {
                Button("OK", role: .cancel) {
                    dashboardViewModel.deleteLinkErrorAlert = false
                }
            } message: {
                Text("An error occured when deleting the link. Try again later.")
            }
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
