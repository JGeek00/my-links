import SwiftUI

struct DashboardView: View {
    @State private var dashboardViewModel: DashboardViewModel
    
    init() {
        _dashboardViewModel = State(initialValue: DashboardViewModel())
    }
        
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.openURL) private var openURL
        
    var body: some View {
        @Bindable var dashboardViewModel = dashboardViewModel

        GeometryReader { proxy in
            NavigationSplitView(preferredCompactColumn: $dashboardViewModel.preferredColumn) {
                DashboardLeftPane(width: proxy.size.width, isRegular: horizontalSizeClass == .regular)
                    .navigationSplitViewColumnWidth(min: proxy.size.width / 3, ideal: proxy.size.width / 3, max: proxy.size.width / 3)
            } detail: {
                if let selected = dashboardViewModel.selectedLink {
                    NavigationStack {
                        DashboardDetailView(linkOpen: selected)
                    }
                }
                else if horizontalSizeClass == .regular {
                    ContentUnavailableView("Choose a link", systemImage: "link", description: Text("Select a link from the left column"))
                }
                else {
                    EmptyView()
                }
            }
        }
        .task {
            await dashboardViewModel.loadData()
        }
        .environment(dashboardViewModel)
        .toolbar(horizontalSizeClass == .compact && dashboardViewModel.preferredColumn == .detail ? .hidden : .visible, for: .tabBar)
    }
}
