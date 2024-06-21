import SwiftUI
import CustomAlert

struct DashboardView: View {
    @StateObject private var dashboardViewModel = DashboardViewModel.shared
    @EnvironmentObject private var tagsProvider: TagsProvider
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    @EnvironmentObject private var linkFormViewModel: LinkFormViewModel
    @EnvironmentObject private var collectionFormViewModel: CollectionFormViewModel
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    init() {}
    
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                            Task { await dashboardViewModel.loadData(setLoading: true) }
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                else {
                    let filtered = dashboardViewModel.data.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.url != nil && $0.tags != nil && $0.collection?.id != nil }
                    let pinned = filtered.filter() { $0.pinnedBy != nil && $0.pinnedBy!.isEmpty == false }
                    List {
                        Section {
                            if horizontalSizeClass == .regular {
                                HStack(spacing: 12) {
                                    SummaryEntry(icon: "link", label: "Links", value: (collectionsProvider.data.map() { $0._count!.links! }).reduce(0, +), color: Color.green, status: collectionsProvider.loading == true ? .loading : collectionsProvider.error == true ? .error : .loaded)
                                    SummaryEntry(icon: "pin.fill", label: "Pinned", value: dashboardViewModel.data.filter() { $0.pinnedBy!.isEmpty == false }.count, color: Color.orange, status: .loaded)
                                    SummaryEntry(icon: "folder.fill", label: "Collections", value: collectionsProvider.data.count, color: Color.blue, status: collectionsProvider.loading == true ? .loading : collectionsProvider.error == true ? .error : .loaded)
                                    SummaryEntry(icon: "tag.fill", label: "Tags", value: tagsProvider.data.count, color: Color.red, status: tagsProvider.loading == true ? .loading : tagsProvider.error == true ? .error : .loaded)
                                }
                            }
                            else {
                                VStack(spacing: 12) {
                                    HStack(spacing: 12) {
                                        SummaryEntry(icon: "link", label: "Links", value: (collectionsProvider.data.map() { $0._count!.links! }).reduce(0, +), color: Color.green, status: collectionsProvider.loading == true ? .loading : collectionsProvider.error == true ? .error : .loaded)
                                        SummaryEntry(icon: "pin.fill", label: "Pinned", value: dashboardViewModel.data.filter() { $0.pinnedBy!.isEmpty == false }.count, color: Color.orange, status: .loaded)
                                    }
                                    HStack(spacing: 12) {
                                        SummaryEntry(icon: "folder.fill", label: "Collections", value: collectionsProvider.data.count, color: Color.blue, status: collectionsProvider.loading == true ? .loading : collectionsProvider.error == true ? .error : .loaded)
                                        SummaryEntry(icon: "tag.fill", label: "Tags", value: tagsProvider.data.count, color: Color.red, status: tagsProvider.loading == true ? .loading : tagsProvider.error == true ? .error : .loaded)
                                    }
                                }
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .padding(.top, 16)
                        if !filtered.isEmpty {
                            Section {
                                ForEach(filtered.uniqued(), id: \.self) { item in
                                    LinkItemComponent(item: item) {
                                        openSafariView(item.url!)
                                    } onTaskCompleted: {
                                        dashboardViewModel.reload()
                                    }
                                }
                            } header: {
                                HStack {
                                    Text("Recent")
                                    Spacer()
                                    Button {
                                        let request = LinksFilteredRequest(name: String(localized: "Recent"), mode: .recent, id: nil)
                                        navigationPath.append(request)
                                    } label: {
                                        Text("View all")
                                        Image(systemName: "chevron.right")
                                    }
                                    .font(.system(size: 12))
                                }
                            }
                            if !pinned.isEmpty {
                                Section {
                                    ForEach(pinned.uniqued(), id: \.self) { item in
                                        LinkItemComponent(item: item) {
                                            openSafariView(item.url!)
                                        } onTaskCompleted: {
                                            dashboardViewModel.reload()
                                        }
                                    }
                                } header: {
                                    HStack {
                                        Text("Pinned")
                                        Spacer()
                                        Button {
                                            let request = LinksFilteredRequest(name: String(localized: "Pinned"), mode: .pinned, id: nil)
                                            navigationPath.append(request)
                                        } label: {
                                            Text("View all")
                                            Image(systemName: "chevron.right")
                                        }
                                    }
                                    .font(.system(size: 12))
                                }
                            }
                        }
                        else {
                            ContentUnavailableView {
                                Label("No links added", systemImage: "link")
                            } description: {
                                Text("Save some links on Linkwarden to see them here.")
                            }
                            .listRowBackground(Color.clear)
                        }
                    }
                    .animation(.default, value: dashboardViewModel.data)
                    .refreshable {
                        await dashboardViewModel.loadData()
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            linkFormViewModel.reset()
                            linkFormViewModel.sheetOpen.toggle()
                        } label: {
                            Label("New link", systemImage: "link")
                        }
                        Button {
                            collectionFormViewModel.reset()
                            collectionFormViewModel.sheetOpen.toggle()
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
                LinksFilteredView(input: value)
            }
        }
        .onAppear(perform: {
            if dashboardViewModel.data.isEmpty {
                Task { await dashboardViewModel.loadData() }
            }
        })
    }
}

private struct SummaryEntry: View {
    var icon: String
    var label: String
    var value: Int
    var color: Color
    var status: Enums.Status
    
    init(icon: String, label: String, value: Int, color: Color, status: Enums.Status) {
        self.icon = icon
        self.label = label
        self.value = value
        self.color = color
        self.status = status
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Image(systemName: icon)
                    .frame(width: 32, height: 32)
                    .background(color)
                    .foregroundStyle(Color.white)
                    .clipShape(Circle())
                Spacer()
                    .frame(height: 12)
                Text(LocalizedStringKey(label))
                    .lineLimit(1)
                    .foregroundStyle(Color.dashboardSummaryText)
                    .fontWeight(.semibold)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Group {
                    if status == .loading {
                        ProgressView()
                    }
                    else if status == .error {
                        Image(systemName: "exclamationmark.circle")
                    }
                    else {
                        Text(String(value))
                    }
                }
                .fontWeight(.bold)
                .font(.system(size: 24))
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.listItemBackground)
        .cornerRadius(12)
    }
}
