import SwiftUI

struct Header: View {
    var dashboardData: DashboardResponse_Data
    var isSingleColumn: Bool
    
    init(dashboardData: DashboardResponse_Data, isSingleColumn: Bool = false) {
        self.dashboardData = dashboardData
        self.isSingleColumn = isSingleColumn
    }
    
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    
    var body: some View {
        Group {
            if isSingleColumn {
                VStack(spacing: 12) {
                    linksEntry
                    pinnedEntry
                    collectionsEntry
                    tagsEntry
                }
            }
            else {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        linksEntry
                        pinnedEntry
                    }
                    HStack(spacing: 12) {
                        collectionsEntry
                        tagsEntry
                    }
                }
            }
        }
        .padding(.top, 8)
        .padding(.leading, -16)
        .padding(.trailing, -16)
    }

    private var linksEntry: some View {
        SummaryEntry(icon: "link", label: "Links", value: (dashboardViewModel.collections.map() { $0._count!.links! }).reduce(0, +), color: Color.green, status: dashboardViewModel.loadingCollections == true ? .loading : dashboardViewModel.errorCollections == true ? .error : .loaded) {
            dashboardViewModel.navigateLinksCatalog()
        }
    }

    private var pinnedEntry: some View {
        SummaryEntry(icon: "pin.fill", label: "Pinned", value: dashboardData.numberOfPinnedLinks, color: Color.orange, status: .loaded) {
            dashboardViewModel.navigatePinned()
        }
    }

    private var collectionsEntry: some View {
        SummaryEntry(icon: "folder.fill", label: "Collections", value: dashboardViewModel.collections.count, color: Color.blue, status: dashboardViewModel.loadingCollections == true ? .loading : dashboardViewModel.errorCollections == true ? .error : .loaded) {
            dashboardViewModel.navigateCollectionsCatalog()
        }
    }

    private var tagsEntry: some View {
        SummaryEntry(icon: "tag.fill", label: "Tags", value: dashboardData.numberOfTags, color: Color.red, status: .loaded) {
            dashboardViewModel.navigateTagsCatalog()
        }
    }
}

fileprivate struct SummaryEntry: View {
    var icon: String
    var label: String
    var value: Int?
    var color: Color
    var status: Enums.Status
    var onTap: () -> Void
    
    init(icon: String, label: String, value: Int?, color: Color, status: Enums.Status, onTap: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.value = value
        self.color = color
        self.status = status
        self.onTap = onTap
    }
    
    var body: some View {
        Button {
            onTap()
        } label: {
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
            .padding(16)
            .background(Color.listItemBackground)
            .cornerRadius(24)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
