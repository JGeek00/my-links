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
        .onAppear(perform: {
            if dashboardViewModel.data.isEmpty {
                Task { await dashboardViewModel.loadData() }
            }
        })
    }
}

struct DashboardRegularView: View {
    @EnvironmentObject private var dashboardViewModel: DashboardViewModel
    
    @AppStorage(StorageKeys.showPinnedBeforeRecent, store: UserDefaults.shared) private var showPinnedBeforeRecent: Bool = false
    
    var body: some View {
        ScrollView {
            Header(dashboardData: dashboardViewModel.data)
            if showPinnedBeforeRecent == true {
                DashboardRegularViewPinned()
                DashboardRegularViewRecent()
            }
            else {
                DashboardRegularViewRecent()
                DashboardRegularViewPinned()
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
    
    @AppStorage(StorageKeys.showPinnedBeforeRecent, store: UserDefaults.shared) private var showPinnedBeforeRecent: Bool = false
    
    var body: some View {
        List {
            Section {} header: {
                Header(dashboardData: dashboardViewModel.data)
            }
            if showPinnedBeforeRecent == true {
                DashboardCompactViewPinned()
                DashboardCompactViewRecent()
            }
            else {
                DashboardCompactViewRecent()
                DashboardCompactViewPinned()
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
