import SwiftUI

struct DashboardCompactViewRecent: View {
    @EnvironmentObject private var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        let filtered = dashboardViewModel.data.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.tags != nil && $0.collection?.id != nil }
        Section {
            ForEach(filtered.uniqued(), id: \.self) { item in
                LinkItemComponent(item: item) { link, action in
                    dashboardViewModel.reload()
                }
            }
            .overlay(alignment: .center) {
                if filtered.isEmpty {
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
    @EnvironmentObject private var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        let filtered = dashboardViewModel.data.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.tags != nil && $0.collection?.id != nil }
        let pinned = filtered.filter() { $0.pinnedBy != nil && $0.pinnedBy!.isEmpty == false }
        if !pinned.isEmpty {
            Section {
                ForEach(pinned.uniqued(), id: \.self) { item in
                    LinkItemComponent(item: item) { link, action in
                        dashboardViewModel.reload()
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
