import SwiftUI

struct ElementsView: View {
    @State private var elementsViewModel: ElementsViewModel
    
    init() {
        _elementsViewModel = State(initialValue: ElementsViewModel())
    }
        
    var body: some View {
        NavigationSplitView {
            List(selection: $elementsViewModel.catalogSelectedView) {
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
            if let selectedView = elementsViewModel.catalogSelectedView {
                switch selectedView {
                case .links:
                    NavigationStack {
                        LinksView()
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background(Color.listBackground)
    }
}
