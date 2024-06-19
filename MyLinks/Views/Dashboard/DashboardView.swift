import SwiftUI

struct DashboardView: View {
    @StateObject private var dashboardViewModel = DashboardViewModel()
    @EnvironmentObject private var tagsProvider: TagsProvider
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    @EnvironmentObject private var linkFormViewModel: LinkFormViewModel
    @EnvironmentObject private var collectionFormViewModel: CollectionFormViewModel
    
    init() {}
    
    var body: some View {
        NavigationStack {
            Group {
                if dashboardViewModel.loading == true {
                    ProgressView()
                }
                else if dashboardViewModel.error == true {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.circle")
                    } description: {
                        Text("An error occured when loading the dashboard data. Check your Internet connection and try again later.")
                        Button {
                            dashboardViewModel.loadData(setLoading: true)
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                else {
                    List {
                        Section {
                            HStack {
                                SummaryEntry(icon: "link", label: "Links", value: dashboardViewModel.data?.response?.uniqued().count ?? 0, color: Color.green, status: .loaded)
                                    .frame(maxWidth: .infinity)
                                Divider()
                                    .padding(.vertical, 6)
                                SummaryEntry(icon: "folder.fill", label: "Collections", value: collectionsProvider.data?.response?.count ?? 0, color: Color.blue, status: collectionsProvider.loading == true ? .loading : collectionsProvider.error == true ? .error : .loaded)
                                    .frame(maxWidth: .infinity)
                                Divider()
                                    .padding(.vertical, 6)
                                SummaryEntry(icon: "tag.fill", label: "Tags", value: tagsProvider.data?.response?.count ?? 0, color: Color.red, status: tagsProvider.loading == true ? .loading : tagsProvider.error == true ? .error : .loaded)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        if (dashboardViewModel.data?.response != nil) {
                            let filtered = dashboardViewModel.data!.response!.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.url != nil && $0.tags != nil && $0.collection?.id != nil }
                            let pinned = filtered.filter() { $0.pinnedBy != nil && $0.pinnedBy!.isEmpty == false }
                            Section("Recent") {
                                ForEach(filtered.uniqued(), id: \.self) { item in
                                    LinkItemComponent(item: item) {
                                        openSafariView(item.url!)
                                    }
                                }
                            }
                            Section("Pinned") {
                                ForEach(pinned.uniqued(), id: \.self) { item in
                                    LinkItemComponent(item: item) {
                                        openSafariView(item.url!)
                                    }
                                }
                            }
                        }
                    }
                    .refreshable {
                        dashboardViewModel.loadData()
                    }
                }
            }
            .navigationTitle("Dashboard")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            linkFormViewModel.sheetOpen.toggle()
                        } label: {
                            Label("New link", systemImage: "link")
                        }
                        Button {
                            collectionFormViewModel.sheetOpen.toggle()
                        } label: {
                            Label("New collection", systemImage: "folder")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }

                }
            }
        }
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
        Section {
            VStack {
                Image(systemName: icon)
                    .frame(width: 32, height: 32)
                    .background(color)
                    .foregroundStyle(Color.white)
                    .cornerRadius(8)
                Spacer()
                    .frame(height: 6)
                Text(label)
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
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
