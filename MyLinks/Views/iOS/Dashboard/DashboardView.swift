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
                LinksFilteredView()
                    .environmentObject(LinksFilteredViewModel(input: value))
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
                        Button {
                            let request = LinksFilteredRequest(name: String(localized: "Recent"), mode: .recent, id: nil)
                            dashboardViewModel.path.append(request)
                        } label: {
                            Text("View all")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 16))
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
                        Button {
                            let request = LinksFilteredRequest(name: String(localized: "Pinned"), mode: .pinned, id: nil)
                            dashboardViewModel.path.append(request)
                        } label: {
                            Text("View all")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 16))
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
                        Button {
                            let request = LinksFilteredRequest(name: String(localized: "Recent"), mode: .recent, id: nil)
                            dashboardViewModel.path.append(request)
                        } label: {
                            Text("View all")
                            Image(systemName: "chevron.right")
                        }
                        .font(.system(size: 12))
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
                        Button {
                            let request = LinksFilteredRequest(name: String(localized: "Pinned"), mode: .pinned, id: nil)
                            dashboardViewModel.path.append(request)
                        } label: {
                            Text("View all")
                            Image(systemName: "chevron.right")
                        }
                    }
                    .font(.system(size: 12))
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

fileprivate struct Header: View {
    var dashboardData: [Link]
    
    init(dashboardData: [Link]) {
        self.dashboardData = dashboardData
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @EnvironmentObject private var tagsProvider: TagsProvider
    @EnvironmentObject private var dashboardViewModel: DashboardViewModel
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    
    var body: some View {
        if horizontalSizeClass == .regular {
            Section {
                HStack(spacing: 16) {
                    SummaryEntry(icon: "link", label: "Links", value: (collectionsProvider.data.map() { $0._count!.links! }).reduce(0, +), color: Color.green, status: collectionsProvider.loading == true ? .loading : collectionsProvider.error == true ? .error : .loaded)
                    SummaryEntry(icon: "pin.fill", label: "Pinned", value: dashboardViewModel.pinnedLinks, color: Color.orange, status: .loaded)
                    SummaryEntry(icon: "folder.fill", label: "Collections", value: collectionsProvider.data.count, color: Color.blue, status: collectionsProvider.loading == true ? .loading : collectionsProvider.error == true ? .error : .loaded)
                    SummaryEntry(icon: "tag.fill", label: "Tags", value: tagsProvider.data.count, color: Color.red, status: tagsProvider.loading == true ? .loading : tagsProvider.error == true ? .error : .loaded)
                }
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .padding(16)
        }
        else {
            Section {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        SummaryEntry(icon: "link", label: "Links", value: (collectionsProvider.data.map() { $0._count!.links! }).reduce(0, +), color: Color.green, status: collectionsProvider.loading == true ? .loading : collectionsProvider.error == true ? .error : .loaded)
                        SummaryEntry(icon: "pin.fill", label: "Pinned", value: dashboardViewModel.pinnedLinks, color: Color.orange, status: .loaded)
                    }
                    HStack(spacing: 12) {
                        SummaryEntry(icon: "folder.fill", label: "Collections", value: collectionsProvider.data.count, color: Color.blue, status: collectionsProvider.loading == true ? .loading : collectionsProvider.error == true ? .error : .loaded)
                        SummaryEntry(icon: "tag.fill", label: "Tags", value: tagsProvider.data.count, color: Color.red, status: tagsProvider.loading == true ? .loading : tagsProvider.error == true ? .error : .loaded)
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .padding(.top, 16)
        }
    }
}

fileprivate struct SummaryEntry: View {
    var icon: String
    var label: String
    var value: Int?
    var color: Color
    var status: Enums.Status
    
    init(icon: String, label: String, value: Int?, color: Color, status: Enums.Status) {
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
                        if let value = value {
                            Text(String(value))
                                .foregroundStyle(Color.foreground)
                        }
                        else {
                            Text("N/A")
                        }
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

fileprivate struct TabletListEntry: View {
    var item: Link
    var onTaskCompleted: (Link, Enums.LinkTaskCompleted) -> Void
    
    init(item: Link, onTaskCompleted: @escaping (Link, Enums.LinkTaskCompleted) -> Void) {
        self.item = item
        self.onTaskCompleted = onTaskCompleted
    }
    
    var body: some View {
        Group {
            LinkItemComponent(item: item) { link, action in
                onTaskCompleted(link, action)
            }
        }
        .background(Color.listBackground)
    }
}

fileprivate struct DashboardIndicators: View {
    @EnvironmentObject private var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        if dashboardViewModel.loading == true || dashboardViewModel.error == true {
            Group {
                if dashboardViewModel.loading == true {
                    Group {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
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
                    .transition(.opacity)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .background(Color.listBackground)
        }
    }
}
