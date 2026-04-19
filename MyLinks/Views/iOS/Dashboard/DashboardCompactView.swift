import SwiftUI

struct DashboardCompactViewRecent: View {
    let data: DashboardResponse_Data
    
    init(data: DashboardResponse_Data) {
        self.data = data
    }
    
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    
    var body: some View {
        Section {
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
            }
            .overlay(alignment: .center) {
                if data.links.isEmpty {
                    ContentUnavailableView {
                        Label("No links added", systemImage: "link")
                    } description: {
                        Text("Save some links on Linkwarden to see them here.")
                    }
                    .listRowBackground(Color.clear)
                }
            }
        } header: {
            HStack {
                Text("Recent")
                Spacer()
                ViewAllButton {
                    dashboardViewModel.navigateRecent()
                }
            }
        }
    }
}


struct DashboardCompactViewPinned: View {
    let data: DashboardResponse_Data
    
    init(data: DashboardResponse_Data) {
        self.data = data
    }
    
    @Environment(DashboardViewModel.self) private var dashboardViewModel
    
    var body: some View {
        let pinned = data.links.filter() { $0.pinnedBy?.isEmpty == false }
        if !pinned.isEmpty {
            Section {
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
                }
            } header: {
                HStack {
                    Text("Pinned")
                    Spacer()
                    ViewAllButton {
                        dashboardViewModel.navigatePinned()
                    }
                }
            }
        }
    }
}
