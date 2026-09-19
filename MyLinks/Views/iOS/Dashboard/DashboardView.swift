import SwiftUI

struct DashboardView: View {
    @State private var dashboardViewModel: DashboardViewModel
    
    init() {
        _dashboardViewModel = State(initialValue: DashboardViewModel())
    }
        
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.openURL) private var openURL
            
    var body: some View {
        GeometryReader { proxy in
            CustomAdaptiveLayout(splitViewPreferredColumn: $dashboardViewModel.preferredColumn) { mode in
                switch mode {
                case .arrangementView:
                    DashboardLeftPane(headerSingleColumn: false, showSelectedLink: true)
                case .splitView:
                    DashboardLeftPane(headerSingleColumn: horizontalSizeClass == .regular && (proxy.size.width < 300), showSelectedLink: horizontalSizeClass == .regular)
                }
            } secondaryView: { _ in
                Group {
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
        }
        .task {
            await dashboardViewModel.loadData()
        }
        .environment(dashboardViewModel)
    }
}
