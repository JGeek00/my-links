import SwiftUI

struct Sidebar: View {    
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    @EnvironmentObject private var tagsProvider: TagsProvider
    
    var body: some View {
        let collections = collectionsProvider.data.filter() { $0.parent?.id == nil && $0.parent?.name == nil }
        VStack(alignment :.leading) {
            Group {
                HStack(spacing: 6) {
                    VStack(spacing: 6) {
                        SidebarButton(image: "house.fill", name: "Dashboard", color: .green, dashboardView: .dashboard)
                        SidebarButton(image: "pin.fill", name: "Pinned", color: .red, dashboardView: .pinned)
                    }
                    VStack(spacing: 6) {
                        SidebarButton(image: "link", name: "Links", color: .blue, dashboardView: .links)
                        SidebarButton(image: "folder.fill", name: "Collections", color: .orange, dashboardView: .collections)
                    }
                }
            }
            .padding(6)
            List {
                if !collections.isEmpty {
                    Section("Collections") {
                        ForEach(collections, id: \.self) { item in
                            NavigationLink {
                                LinksFilteredView(input: LinksFilteredRequest(name: item.name!, mode: .collection, id: item.id!))
                            } label: {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundStyle(Color(hex: item.color!))
                                    Spacer()
                                        .frame(width: 6)
                                    Text(item.name!)
                                    Spacer()
                                    if let count = item._count?.links {
                                        Text(String(count))
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                        }
                    }
                    .collapsible(true)
                }
                if !tagsProvider.data.isEmpty {
                    Section("Tags") {
                        ForEach(tagsProvider.data, id: \.self) { item in
                            NavigationLink {
                                LinksFilteredView(input: LinksFilteredRequest(name: item.name!, mode: .tag, id: item.id!))
                            } label: {
                                HStack {
                                    Image(systemName: "tag.fill")
                                    Spacer()
                                        .frame(width: 6)
                                    Text(item.name!)
                                    Spacer()
                                    if let count = item._count?.links {
                                        Text(String(count))
                                    }
                                }
                                .contentShape(Rectangle())
                            }
                        }
                    }
                    .collapsible(true)
                }
            }
        }
    }
}

private struct SidebarButton: View {
    var image: String
    var name: String
    var color: Color
    var dashboardView: Enums.DashboardView
    
    init(image: String, name: String, color: Color, dashboardView: Enums.DashboardView) {
        self.image = image
        self.name = name
        self.color = color
        self.dashboardView = dashboardView
    }
    
    var body: some View {
        NavigationLink {
            switch dashboardView {
            case .dashboard:
                DashboardView()
            case .links:
                LinksView()
            case .pinned:
                LinksFilteredView(input: LinksFilteredRequest(name: "Pinned", mode: .pinned, id: nil))
            case .collections:
                CollectionsView()
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Image(systemName: image)
                        .frame(width: 28, height: 28)
                        .background(color)
                        .foregroundStyle(Color.white)
                        .clipShape(Circle())
                    Spacer()
                        .frame(height: 12)
                    Text(LocalizedStringKey(name))
                        .lineLimit(1)
                        .fontWeight(.semibold)
                }
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(6)
        }
        .background(Material.ultraThin)
        .cornerRadius(12)
    }
}
