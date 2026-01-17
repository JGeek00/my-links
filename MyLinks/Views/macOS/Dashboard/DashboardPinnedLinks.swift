import SwiftUI

struct DashboardPinnedLinks: View {
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
                    NavigationLink {
                        LinksFilteredView(input: LinksFilteredRequest(name: String(localized: "Pinned"), mode: .pinned, id: nil))
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
