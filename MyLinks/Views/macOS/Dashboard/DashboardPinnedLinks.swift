import SwiftUI

struct DashboardPinnedLinks: View {
    var pinned: [Link]
    
    init(pinned: [Link]) {
        self.pinned = pinned
    }
    
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    
    var body: some View {        
        if !pinned.isEmpty {
            VStack {
                HStack {
                    Text("Pinned")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    Spacer()
                    NavigationLink {
                        LinksFilteredView(linksFilteredRequest: LinksFilteredRequest(name: String(localized: "Pinned"), mode: .pinned, id: nil))
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
                        LinkItemComponent(item: item) { l, id, action in
                            switch action {
                            case .edit:
                                dashboardViewModel.handleEditLink(link: l!)
                            case .delete:
                                dashboardViewModel.handleDeleteLink(linkId: id!)
                            }
                        } onPinUnpin: { l, action in
                            dashboardViewModel.handlePinUnpin(link: l, action: action)
                        }
                        .padding(6)
                    }
                }
            }
            .padding(8)
        }
    }
}
