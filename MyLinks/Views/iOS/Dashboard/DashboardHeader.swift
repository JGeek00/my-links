import SwiftUI

struct Header: View {
    var dashboardData: DashboardResponse_Data
    
    init(dashboardData: DashboardResponse_Data) {
        self.dashboardData = dashboardData
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    @EnvironmentObject private var navigationProvider: NavigationProvider
    
    var body: some View {
        if horizontalSizeClass == .regular {
            Section {
                HStack(spacing: 16) {
                    SummaryEntry(icon: "link", label: "Links", value: (collectionsProvider.data.map() { $0._count!.links! }).reduce(0, +), color: Color.green, status: collectionsProvider.loading == true ? .loading : collectionsProvider.error == true ? .error : .loaded) {
                        navigationProvider.navigateLinksCatalog()
                    }
                    SummaryEntry(icon: "pin.fill", label: "Pinned", value: dashboardData.numberOfPinnedLinks, color: Color.orange, status: .loaded) {
                        dashboardViewModel.navigatePinned()
                    }
                    SummaryEntry(icon: "folder.fill", label: "Collections", value: collectionsProvider.data.count, color: Color.blue, status: collectionsProvider.loading == true ? .loading : collectionsProvider.error == true ? .error : .loaded) {
                        navigationProvider.navigateCollectionsCatalog()
                    }
                    SummaryEntry(icon: "tag.fill", label: "Tags", value: dashboardData.numberOfTags, color: Color.red, status: .loaded) {
                        navigationProvider.navigateTagsCatalog()
                    }
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
                        SummaryEntry(icon: "link", label: "Links", value: (collectionsProvider.data.map() { $0._count!.links! }).reduce(0, +), color: Color.green, status: collectionsProvider.loading == true ? .loading : collectionsProvider.error == true ? .error : .loaded) {
                            navigationProvider.navigateLinksCatalog()
                        }
                        SummaryEntry(icon: "pin.fill", label: "Pinned", value: dashboardData.numberOfPinnedLinks, color: Color.orange, status: .loaded) {
                            dashboardViewModel.navigatePinned()
                        }
                    }
                    HStack(spacing: 12) {
                        SummaryEntry(icon: "folder.fill", label: "Collections", value: collectionsProvider.data.count, color: Color.blue, status: collectionsProvider.loading == true ? .loading : collectionsProvider.error == true ? .error : .loaded) {
                            navigationProvider.navigateCollectionsCatalog()
                        }
                        SummaryEntry(icon: "tag.fill", label: "Tags", value: dashboardData.numberOfTags, color: Color.red, status: .loaded) {
                            navigationProvider.navigateTagsCatalog()
                        }
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            .padding(.top, 16)
        }
    }
}

struct SummaryEntry: View {
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
