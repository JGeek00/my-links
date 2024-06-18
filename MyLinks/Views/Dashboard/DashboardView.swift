import SwiftUI

struct DashboardView: View {
    @StateObject private var dashboardViewModel = DashboardViewModel()
    
    init() {}
    
    var body: some View {
        NavigationStack {
            Group {
                if dashboardViewModel.loading == true {
                    ProgressView()
                }
                else if dashboardViewModel.error == true {
            
                }
                else {
                    List {
                        Section {
                            HStack {
                                SummaryEntry(icon: "link", label: "Links", value: dashboardViewModel.dashboard?.response?.count ?? 0, color: Color.green)
                                    .frame(maxWidth: .infinity)
                                Divider()
                                    .padding(.vertical, 6)
                                SummaryEntry(icon: "folder.fill", label: "Collections", value: dashboardViewModel.collections?.response?.count ?? 0, color: Color.blue)
                                    .frame(maxWidth: .infinity)
                                Divider()
                                    .padding(.vertical, 6)
                                SummaryEntry(icon: "tag.fill", label: "Tags", value: dashboardViewModel.tags?.response?.count ?? 0, color: Color.red)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        if (dashboardViewModel.dashboard?.response != nil) {
                            let filtered = dashboardViewModel.dashboard!.response!.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.url != nil }
                            let pinned = filtered.filter() { $0.pinnedBy != nil && $0.pinnedBy!.isEmpty == false }
                            Section("Recent") {
                                ForEach(Array(Set(filtered)), id: \.self) { item in
                                    LinkEntry(item: item)
                                }
                            }
                            Section("Pinned") {
                                ForEach(Array(Set(pinned)), id: \.self) { item in
                                    LinkEntry(item: item)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
        }
        .onAppear(perform: {
            dashboardViewModel.loadData()
        })
    }
}

private struct SummaryEntry: View {
    var icon: String
    var label: String
    var value: Int
    var color: Color
    
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
                Text(String(value))
                    .fontWeight(.semibold)
            }
        }
    }
}

private struct LinkEntry: View {
    var item: DashboardResponse
    
    init(item: DashboardResponse) {
        self.item = item
    }
    
    var body: some View {
        let urlHost = getUrlHost(item.url!)
        let dateFormatted = item.createdAt != nil ? formatDate(item.createdAt!) : nil
        VStack(alignment: .leading) {
            Text(item.name != "" ? item.name! : item.description != "" ? item.description! : item.url!)
                .lineLimit(1)
                .fontWeight(.medium)
            if urlHost != nil {
                Spacer()
                    .frame(height: 4)
                HStack {
                    Image(systemName: "link")
                        .font(.system(size: 10))
                    Text(urlHost!)
                        .font(.system(size: 14))
                }
                .foregroundStyle(Color.gray)
            }
            if dateFormatted != nil || (item.collection?.name != nil) {
                Spacer()
                    .frame(height: 4)
                HStack {
                    Image(systemName: "folder")
                        .font(.system(size: 10))
                    Text(item.collection!.name!)
                        .font(.system(size: 14))
                    if dateFormatted != nil {
                        Spacer()
                        Image(systemName: "calendar")
                            .font(.system(size: 12))
                        Text(dateFormatted!)
                            .font(.system(size: 14))
                    }
                }
                .foregroundStyle(Color.gray)
            }
        }
    }
}
