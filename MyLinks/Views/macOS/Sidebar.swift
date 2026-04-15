import SwiftUI

private struct SidebarCollection: Identifiable, Hashable {
    var id: Int
    var name: String
    var color: String
    var count: Int
    var subCollections: [SidebarCollection]
}

private func sidebarCollections(data: [Collection]) -> [SidebarCollection] {
    func findChildren(parent: Collection) -> SidebarCollection {
        let children = data.filter() { $0.parent?.id == parent.id }
        return SidebarCollection(id: parent.id!, name: parent.name!, color: parent.color!, count: parent._count?.links ?? 0, subCollections: children.map() { findChildren(parent: $0) })
    }
    
    let hasParent = (data.filter() { $0.parent?.id != nil }).map() { $0.id }
    let result = data.map() { findChildren(parent: $0) }
    return result.filter() { !hasParent.contains($0.id) }
}

struct Sidebar: View {    
    @EnvironmentObject private var collectionsProvider: CollectionsProvider
    @EnvironmentObject private var tagsProvider: TagsProvider
    
    @State private var idToDelete: Int? = nil
    @State private var errorDeleteAlert: Bool = false
    
    var body: some View {
        let collections = sidebarCollections(data: collectionsProvider.data)
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
                            CollectionItem(item: item)
                        }
                    }
                    .collapsible(true)
                }
                if !tagsProvider.data.isEmpty {
                    Section("Tags") {
                        ForEach(tagsProvider.data, id: \.self) { item in
                            NavigationLink {
                                LinksFilteredView(input: LinksFilteredRequest(name: item.name, mode: .tag, id: item.id))
                            } label: {
                                HStack {
                                    Image(systemName: "tag.fill")
                                    Spacer()
                                        .frame(width: 6)
                                    Text(item.name)
                                    Spacer()
                                    Text(String(item.count.links))
                                }
                                .contentShape(Rectangle())
                            }
                            .contextMenu {
                                Button("Delete tag", role: .destructive) {
                                    idToDelete = item.id
                                }
                            }
                        }
                    }
                    .collapsible(true)
                }
            }
        }
        .alert("Delete tag", isPresented: Binding<Bool>(
            get: { idToDelete != nil },
            set: { newValue in
                if !newValue { idToDelete = nil }
            })) {
            Button("Cancel", role: .cancel) {
                idToDelete = nil
            }
            Button("Delete tag", role: .destructive) {
                let id = idToDelete
                idToDelete = nil
                if let id {
                    Task {
                        let result = await tagsProvider.deleteTag(tagId: id)
                        if result == false {
                            errorDeleteAlert = true
                        }
                    }
                }
            }
        } message: {
            Text("This tag will be deleted. This action is not reversible.")
        }
        .alert("Error", isPresented: $errorDeleteAlert) {
            Button("Close") {
                errorDeleteAlert = false
            }
        } message: {
            Text("An error occured when deleting the tag. Please try again later.")
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
                    .environmentObject(DashboardViewModel.shared)
            case .links:
                LinksView()
            case .pinned:
                LinksFilteredView(input: LinksFilteredRequest(name: String(localized: "Pinned"), mode: .pinned, id: nil))
            case .collections:
                CollectionsView()
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Image(systemName: image)
                        .frame(width: 28, height: 28)
                        .background(color)
                        .foregroundStyle(Color.background)
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

private struct CollectionItem: View {
    var item: SidebarCollection
    
    init(item: SidebarCollection) {
        self.item = item
    }
    
    var body: some View {
        if item.subCollections.isEmpty {
            NavigationLink {
                LinksFilteredView(input: LinksFilteredRequest(name: item.name, mode: .collection, id: item.id))
            } label: {
                HStack {
                    Image(systemName: "folder.fill")
                        .foregroundStyle(Color(hex: item.color))
                    Spacer()
                        .frame(width: 6)
                    Text(item.name)
                    Spacer()
                    Text(String(item.count))
                }
                .contentShape(Rectangle())
            }
        }
        else {
            DisclosureGroup {
                ForEach(item.subCollections, id: \.self) { item in
                    CollectionItem(item: item)
                }
            } label: {
                NavigationLink {
                    LinksFilteredView(input: LinksFilteredRequest(name: item.name, mode: .collection, id: item.id))
                } label: {
                    HStack {
                        if !item.subCollections.isEmpty {
                            Spacer()
                                .frame(width: 6)
                        }
                        Image(systemName: "folder.fill")
                            .foregroundStyle(Color(hex: item.color))
                        Spacer()
                            .frame(width: 6)
                        Text(item.name)
                        Spacer()
                        Text(String(item.count))
                    }
                    .contentShape(Rectangle())
                }
            }
        }
    }
}

