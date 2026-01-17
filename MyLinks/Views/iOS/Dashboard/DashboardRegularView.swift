import SwiftUI

struct DashboardRegularViewRecent: View {
    @EnvironmentObject private var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        let filtered = dashboardViewModel.data.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.tags != nil && $0.collection?.id != nil }
        if !filtered.isEmpty {
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
                    ForEach(filtered.uniqued(), id: \.self) { item in
                        LinkItemComponent(item: item) { link, action in
                            dashboardViewModel.reload()
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
    @EnvironmentObject private var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        let filtered = dashboardViewModel.data.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.tags != nil && $0.collection?.id != nil }
        let pinned = filtered.filter() { $0.pinnedBy != nil && $0.pinnedBy!.isEmpty == false }
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
                        LinkItemComponent(item: item) { link, action in
                            dashboardViewModel.reload()
                        }
                        .padding(6)
                    }
                }
            }
            .padding(8)
        }
    }
}
