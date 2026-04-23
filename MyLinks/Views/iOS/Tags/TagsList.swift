import SwiftUI

struct TagsList: View {
    var loading: Bool
    var error: Bool
    var withSearch: Bool
    var data: [Tag]
    var onReload: () -> Void
    var onDeleteTag: (Tag) -> Void
    var onEditTag: (Tag) -> Void
    var onLoadNextBatch: () -> Void
    
    init(loading: Bool, error: Bool, withSearch: Bool, data: [Tag], onReload: @escaping () -> Void, onDeleteTag: @escaping (Tag) -> Void, onEditTag: @escaping (Tag) -> Void, onLoadNextBatch: @escaping () -> Void) {
        self.loading = loading
        self.error = error
        self.withSearch = withSearch
        self.data = data
        self.onReload = onReload
        self.onDeleteTag = onDeleteTag
        self.onEditTag = onEditTag
        self.onLoadNextBatch = onLoadNextBatch
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
                    Text("An error occured when loading the links data. Check your Internet connection and try again later.")
                    Button {
                        onReload()
                    } label: {
                        Label("Retry", systemImage: "arrow.counterclockwise")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
            else if data.isEmpty && withSearch {
                ContentUnavailableView {
                    Label("No tags found", systemImage: "tag")
                } description: {
                    Text("Change the search term to see some tags.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
            else if data.isEmpty && !withSearch {
                ContentUnavailableView {
                    Label("No tags created", systemImage: "tag")
                } description: {
                    Text("Add tags to links to see them here.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
            else {
                if horizontalSizeClass == .regular {
                    ScrollView {
                        LazyVGrid(columns: Config.gridColumns) {
                            ForEach(data, id: \.self) { item in
                                TagItemComponent(tag: item) { tag in
                                    onDeleteTag(tag)
                                } onEditTag: { tag in
                                    onEditTag(tag)
                                }
                                .padding(6)
                                .onAppear {
                                    if item == data.last {
                                        onLoadNextBatch()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                    .animation(.default, value: data)
                    .transition(.opacity)
                }
                else {
                    List(data, id: \.self) { item in
                        TagItemComponent(tag: item) { tag in
                            onDeleteTag(tag)
                        } onEditTag: { tag in
                            onEditTag(tag)
                        }
                        .onAppear {
                            if item == data.last {
                                onLoadNextBatch()
                            }
                        }
                    }
                    .animation(.default, value: data)
                    .transition(.opacity)
                }
            }
        }
    }
}
