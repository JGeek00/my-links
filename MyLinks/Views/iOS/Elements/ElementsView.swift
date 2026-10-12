import SwiftUI

struct ElementsView: View {
    @State private var elementsViewModel: ElementsViewModel

    init() {
        _elementsViewModel = State(initialValue: ElementsViewModel())
    }

    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    var body: some View {
        @Bindable var elementsViewModel = elementsViewModel

        CustomAdaptiveLayout(splitViewPreferredColumn: $elementsViewModel.preferredColumn) { mode in
            ElementsLeftPane(showSelectedLink: mode == .arrangementView ? true : horizontalSizeClass == .regular)
        } secondaryView: { mode in
            Group {
                if let selected = elementsViewModel.selectedLink {
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
            .background(Color.listBackground)
        }
        .environment(elementsViewModel)
    }
}

private struct ElementsLeftPane: View {
    let showSelectedLink: Bool

    @Environment(ElementsViewModel.self) private var elementsViewModel
    @Environment(\.openURL) private var openURL

    var body: some View {
        @Bindable var elementsViewModel = elementsViewModel

        NavigationStack(path: $elementsViewModel.path) {
            List {
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
            .listStyle(.insetGrouped)
            .navigationDestination(for: Enums.ElementsDetailView.self) { view in
                switch view {
                case .links:
                    LinksView(onLinkTap: handleTap, selectedLinkId: selectedId)
                        .background(Color.listBackground)
                case .collections:
                    CollectionsView(onLinkTap: handleTap, selectedLinkId: selectedId)
                        .background(Color.listBackground)
                case .tags:
                    TagsView(onLinkTap: handleTap, selectedLinkId: selectedId)
                        .background(Color.listBackground)
                }
            }
            .navigationDestination(for: LinksFilteredRequest.self) { request in
                LinksFilteredView(linksFilteredRequest: request, onLinkTap: handleTap, selectedLinkId: selectedId)
            }
            .onAppear {
                elementsViewModel.restoreCatalogSelection()
            }
            .onChange(of: elementsViewModel.catalogSelectedView) {
                elementsViewModel.restoreCatalogSelection()
            }
            .onChange(of: elementsViewModel.path.count) { _, count in
                if count == 0 {
                    elementsViewModel.catalogSelectedView = nil
                }
            }
        }
        .background(Color.listBackground)
    }

    private var selectedId: Int? {
        showSelectedLink ? elementsViewModel.selectedLink?.link.id : nil
    }

    private func handleTap(link: Link, mode: Enums.OpenLinkAction?) {
        if let mode = mode {
            elementsViewModel.navigateDetail(link: link, mode: mode)
        }
        else if let urlString = link.url, let url = URL(string: urlString) {
            openURL(url)
        }
    }
}
