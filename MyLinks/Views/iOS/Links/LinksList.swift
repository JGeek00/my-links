import SwiftUI

struct LinksList: View {
    var loading: Bool
    var error: Bool
    var withSearch: Bool
    var data: [Link]
    var scrollToTop: Bool
    var onEditLink: (Link) -> Void
    var onDeleteLink: (Link) -> Void
    var onLoadMore: () -> Void
    var onReload: () -> Void
    
    init(loading: Bool, error: Bool, withSearch: Bool, data: [Link], scrollToTop: Bool, onEditLink: @escaping (Link) -> Void, onDeleteLink: @escaping (Link) -> Void, onLoadMore: @escaping () -> Void, onReload: @escaping () -> Void) {
        self.loading = loading
        self.error = error
        self.withSearch = withSearch
        self.data = data
        self.scrollToTop = scrollToTop
        self.onEditLink = onEditLink
        self.onDeleteLink = onDeleteLink
        self.onLoadMore = onLoadMore
        self.onReload = onReload
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    var body: some View {
        Group {
            if loading == true {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            }
            else if error == true {
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.circle")
                } description: {
                    Text("An error occured when loading the dashboard data. Check your Internet connection and try again later.")
                    Button {
                        onReload()
                    } label: {
                        Label("Retry", systemImage: "arrow.counterclockwise")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
            else if data.isEmpty && !withSearch {
                ContentUnavailableView {
                    Label("No links added", systemImage: "link")
                } description: {
                    Text("Save some links on Linkwarden to see them here.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
            else if data.isEmpty && withSearch {
                ContentUnavailableView {
                    Label("No links found", systemImage: "link")
                } description: {
                    Text("Change the search term to see some links.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
            else {
                if horizontalSizeClass == .regular {
                    ScrollViewReader(content: { scrollView in
                        ScrollView {
                            LazyVGrid(columns: Config.gridColumns) {
                                ForEach(data, id: \.self) { item in
                                    LinkItemComponent(item: item) { _, _, action in
                                        switch action {
                                        case .edit:
                                            onEditLink(item)
                                        case .delete:
                                            onDeleteLink(item)
                                        }
                                    }
                                    .onAppear {
                                        if item == data.last {
                                            onLoadMore()
                                        }
                                    }
                                    .padding(6)
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                    })
                }
                else {
                    ScrollViewReader { scrollView in
                        List(data, id: \.self) { item in
                            LinkItemComponent(item: item) { _, _, action in
                                switch action {
                                case .edit:
                                    onEditLink(item)
                                case .delete:
                                    onDeleteLink(item)
                                }
                            }
                            .onAppear {
                                if item == data.last {
                                    onLoadMore()
                                }
                            }
                        }
                        .animation(.default, value: data)
                        .onChange(of: scrollToTop, initial: false) {
                            guard let first = data.first else { return }
                            scrollView.scrollTo(first)
                        }
                    }
                }
            }
        }
    }
}
