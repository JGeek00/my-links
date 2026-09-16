import SwiftUI

struct DashboardLeftPane: View {
    let width: CGFloat
    
    init(width: CGFloat) {
        self.width = width
    }
    
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.openURL) private var openURL
    
    @AppStorage(StorageKeys.showPinnedBeforeRecent, store: UserDefaults.shared) private var showPinnedBeforeRecent: Bool = false
    
    @State private var linkFormUrlSheet = false
    @State private var linkFormFileSheet = false
    @State private var collectionFormSheet = false
    
    var body: some View {
        @Bindable var dashboardViewModel = dashboardViewModel
        
        NavigationStack(path: $dashboardViewModel.path) {
            Group {
                if dashboardViewModel.loading == true {
                    ProgressView("Loading...")
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if let data = dashboardViewModel.data  {
                    let pinned = data.links.filter() { $0.pinnedBy?.isEmpty == false }
                    List {
                        Section {} header: {
                            Header(dashboardData: data, isSingleColumn: horizontalSizeClass == .regular && (width/3) < 300)
                        }
                        if showPinnedBeforeRecent == true {
                            linksSection(title: "Pinned", links: pinned, source: .allPinned, hideWhenEmpty: true, onViewAll: dashboardViewModel.navigatePinned)
                            linksSection(title: "Recent", links: data.links, source: .allRecent, hideWhenEmpty: false, onViewAll: dashboardViewModel.navigateRecent)
                        }
                        else {
                            linksSection(title: "Recent", links: data.links, source: .allRecent, hideWhenEmpty: false, onViewAll: dashboardViewModel.navigateRecent)
                            linksSection(title: "Pinned", links: pinned, source: .allPinned, hideWhenEmpty: true, onViewAll: dashboardViewModel.navigatePinned)
                        }
                    }
                    .listStyle(.insetGrouped)
                    .animation(.default, value: data)
                    .refreshable {
                        await dashboardViewModel.loadData()
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
                LinksFilteredView(linksFilteredRequest: value, onLinkTap: { link, mode in
                    if let mode = mode {
                        dashboardViewModel.navigateDetail(link: link, mode: mode, source: source(for: value.mode))
                    }
                    else if let urlString = link.url, let url = URL(string: urlString) {
                        openURL(url)
                    }
                }, selectedLinkId: dashboardViewModel.selectedLink?.link.id)
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
            .background(Color.listBackground)
        }
    }
    
    func source(for mode: Enums.LinksFilteredMode) -> Enums.DashboardSubView? {
        switch mode {
        case .recent:
            return .allRecent
        case .pinned:
            return .allPinned
        default:
            return nil
        }
    }
    
    @ViewBuilder
    func linksSection(title: LocalizedStringKey, links: [Link], source: Enums.DashboardSubView, hideWhenEmpty: Bool, onViewAll: @escaping () -> Void) -> some View {
        if !hideWhenEmpty || !links.isEmpty {
            Section {
                ForEach(links.uniqued(), id: \.self) { item in
                    LinkItemComponent(item: item, onTaskCompleted: { l, id, action in
                        switch action {
                        case .edit:
                            dashboardViewModel.handleEditLink(link: l!)
                        case .delete:
                            dashboardViewModel.handleDeleteLink(linkId: id!)
                        }
                    }, onPinUnpin: { l, action in
                        dashboardViewModel.handlePinUnpin(link: l, action: action)
                    }, onLinkTap: { link, mode in
                        if let mode = mode {
                            dashboardViewModel.navigateDetail(link: link, mode: mode, source: source)
                        }
                        else if let urlString = link.url, let url = URL(string: urlString) {
                            openURL(url)
                        }
                    }, isSelected: dashboardViewModel.isSelected(link: item, source: source))
                }
                .overlay(alignment: .center) {
                    if links.isEmpty {
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
                    Text(title)
                    Spacer()
                    ViewAllButton {
                        onViewAll()
                    }
                }
            }
        }
    }
}
