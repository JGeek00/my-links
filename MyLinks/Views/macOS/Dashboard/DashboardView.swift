import SwiftUI

struct DashboardView: View {
    @StateObject private var dashboardViewModel = DashboardViewModel.shared
    @EnvironmentObject private var tagsProvider: TagsProvider
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    
    @State private var linkFormSheet = false
    @State private var collectionFormSheet = false

    var body: some View {
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
                    if !filtered.isEmpty {
                        VStack {
                            HStack {
                                Text("Recent")
                                    .font(.system(size: 16))
                                    .fontWeight(.semibold)
                                Spacer()
                                NavigationLink {
                                    LinksFilteredView(input: LinksFilteredRequest(name: "Recent", mode: .recent, id: nil))
                                } label: {
                                    Text("View all")
                                    Image(systemName: "chevron.right")
                                }
                                .buttonStyle(BorderlessButtonStyle())
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
                                NavigationLink {
                                    LinksFilteredView(input: LinksFilteredRequest(name: "Pinned", mode: .pinned, id: nil))
                                } label: {
                                    Text("View all")
                                    Image(systemName: "chevron.right")
                                }
                                .buttonStyle(BorderlessButtonStyle())
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
            }
        }
        .navigationTitle("Dashboard")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Menu {
                    Button {
                        linkFormSheet.toggle()
                    } label: {
                        Label("New link", systemImage: "link")
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
        .sheet(isPresented: $linkFormSheet, content: {
            LinkFormView() {
                linkFormSheet = false
            } onSuccess: { newLink, action in
                linkFormSheet = false
            }
            .environmentObject(LinkFormViewModel())
        })
        .sheet(isPresented: $collectionFormSheet, content: {
            CollectionFormView() {
                collectionFormSheet = false
            } onSuccess: { item, action in
                collectionFormSheet = false
            }
            .environmentObject(CollectionFormViewModel())
        })
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
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundStyle(Color.white)
                .frame(width: 40, height: 40)
                .background(color)
                .cornerRadius(6)
            Spacer()
                .frame(width: 12)
            VStack {
                Text(LocalizedStringKey(label))
                    .lineLimit(1)
                    .fontWeight(.bold)
                Spacer()
                    .frame(height: 6)
                if status == .loading {
                    ProgressView()
                }
                else if status == .error {
                    Image(systemName: "exclamationmark.circle")
                }
                else {
                    Text(String(value))
                        .font(.system(size: 18))
                }
            }
            Spacer()
        }
    }
}
