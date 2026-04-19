import SwiftUI

struct DashboardRegularViewRecent: View {
    let data: DashboardResponse_Data
    
    init(data: DashboardResponse_Data) {
        self.data = data
    }
    
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    
    var body: some View {
        if !data.links.isEmpty {
            VStack {
                HStack {
                    Text("Recent")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    Spacer()
                    ViewAllButton {
                        dashboardViewModel.navigateRecent()
                    }
                }
                .padding(.horizontal, 8)
                Spacer()
                    .frame(height: 16)
                LazyVGrid(columns: Config.gridColumns) {
                    ForEach(data.links.uniqued(), id: \.self) { item in
                        LinkItemComponent(item: item) { l, id, action in
                            switch action {
                            case .edit:
                                dashboardViewModel.handleEditLink(link: l!)
                            case .delete:
                                dashboardViewModel.handleDeleteLink(linkId: id!)
                            }
                        } onPinUnpin: { linkId, action in
                            // TODO: handle pin unpin
                        }
                        .padding(6)
                    }
                }
            }
            .padding(8)
        }
    }
}


struct DashboardRegularViewPinned: View {
    let data: DashboardResponse_Data
    
    init(data: DashboardResponse_Data) {
        self.data = data
    }
    
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    
    var body: some View {
        let pinned = data.links.filter() { $0.pinnedBy?.isEmpty == false }
        if !pinned.isEmpty {
            VStack {
                HStack {
                    Text("Pinned")
                        .font(.system(size: 16))
                        .fontWeight(.semibold)
                    Spacer()
                    ViewAllButton {
                        dashboardViewModel.navigatePinned()
                    }
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
                        } onPinUnpin: { linkId, action in
                            // TODO: handle pin unpin
                        }
                        .padding(6)
                    }
                }
            }
            .padding(8)
        }
    }
}
