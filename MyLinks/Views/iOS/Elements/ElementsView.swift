import SwiftUI

struct ElementsView: View {
    @State private var selectedView: Enums.ElementsDetailView? = nil
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedView) {
                NavigationLink(value: Enums.ElementsDetailView.links) {
                    Label("Links", systemImage: "link")
                }
                NavigationLink(value: Enums.ElementsDetailView.collections) {
                    Label("Collections", systemImage: "folder")
                }
                NavigationLink(value: Enums.ElementsDetailView.tags) {
                    Label("Tags", systemImage: "tag")
                }
            }
            .navigationTitle("Elements")
        } detail: {
            if let selectedView = selectedView {
                switch selectedView {
                case .links:
                    NavigationStack {
                        LinksView()
                            .environmentObject(LinksViewModel.shared)
                            .background(Color.listBackground)
                    }
                case .collections:
                    NavigationStack {
                        CollectionsView()
                            .background(Color.listBackground)
                    }
                case .tags:
                    NavigationStack {
                        TagsView()
                            .background(Color.listBackground)
                    }
                }
            } else {
                ContentUnavailableView("Choose one option", systemImage: "list.dash")
                    .background(Color.listBackground)
            }
        }
        .background(Color.listBackground)
    }
}
