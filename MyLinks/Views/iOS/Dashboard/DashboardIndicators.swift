import SwiftUI

struct DashboardIndicators: View {
    @EnvironmentObject private var dashboardViewModel: DashboardViewModel
    
    var body: some View {
        if dashboardViewModel.loading == true || dashboardViewModel.error == true {
            Group {
                if dashboardViewModel.loading == true {
                    Group {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
                }
                else if dashboardViewModel.error == true {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.circle")
                    } description: {
                        Text("An error occured when loading the dashboard data. Check your Internet connection and try again later.")
                        Button {
                            Task { await dashboardViewModel.reloadAll() }
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                    .transition(.opacity)
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .background(Color.listBackground)
        }
    }
}


