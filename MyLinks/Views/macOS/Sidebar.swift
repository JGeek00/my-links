import SwiftUI

struct Sidebar: View {
    var onSelect: (Enums.DashboardView) -> Void
        
    init(onSelect: @escaping (Enums.DashboardView) -> Void) {
        self.onSelect = onSelect
    }
    
    var body: some View {
        ScrollView {
            Group {
                HStack(spacing: 6) {
                    VStack(spacing: 6) {
                        SidebarButton(image: "house.fill", name: "Dashboard", color: .green) {
                            onSelect(Enums.DashboardView.dashboard)
                        }
                        SidebarButton(image: "pin.fill", name: "Pinned", color: .red) {
                            onSelect(Enums.DashboardView.pinned)
                        }
                    }
                    VStack(spacing: 6) {
                        SidebarButton(image: "link", name: "Links", color: .blue) {
                            onSelect(Enums.DashboardView.links)
                        }
                        SidebarButton(image: "folder.fill", name: "Collections", color: .orange) {
                            onSelect(Enums.DashboardView.collections)
                        }
                    }
                }
            }
            .padding(6)
        }
    }
}

private struct SidebarButton: View {
    var image: String
    var name: String
    var color: Color
    var onSelect: () -> Void
    
    init(image: String, name: String, color: Color, onSelect: @escaping () -> Void) {
        self.image = image
        self.name = name
        self.color = color
        self.onSelect = onSelect
    }
    
    var body: some View {
        Button {
            onSelect()
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
