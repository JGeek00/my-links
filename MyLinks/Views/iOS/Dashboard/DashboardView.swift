import SwiftUI

struct DashboardView: View {
    @State private var dashboardViewModel: DashboardViewModel
    
    init() {
        _dashboardViewModel = State(initialValue: DashboardViewModel())
    }
        
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
            
    var body: some View {
        @Bindable var dashboardViewModel = dashboardViewModel

        CustomAdaptiveLayout(splitViewPreferredColumn: $dashboardViewModel.preferredColumn) { mode in
            DashboardMainPane(mode: mode, horizontalSizeClass: horizontalSizeClass)
        } secondaryView: { mode in
            Group {
                if let selected = dashboardViewModel.selectedLink {
                    NavigationStack {
                        DashboardDetailView(linkOpen: selected, isArrangementView: mode == .arrangementView)
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
    }
}

/// Same view type in both layout modes so SwiftUI keeps the subtree identity.
private struct DashboardMainPane: View {
    let mode: AdaptiveLayoutMode
    let horizontalSizeClass: UserInterfaceSizeClass?

    var body: some View {
        GeometryReader { proxy in
            DashboardLeftPane(
                headerSingleColumn: headerSingleColumn(width: proxy.size.width),
                showSelectedLink: showSelectedLink
            )
        }
    }

    private var showSelectedLink: Bool {
        switch mode {
        case .arrangementView:
            return true
        case .splitView:
            return horizontalSizeClass == .regular
        }
    }

    private func headerSingleColumn(width: CGFloat) -> Bool {
        switch mode {
        case .arrangementView:
            return false
        case .splitView:
            return horizontalSizeClass == .regular && width < 300
        }
    }
}
