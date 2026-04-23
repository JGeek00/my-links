import SwiftUI

struct TagsView: View {
    @State private var tagsViewModel: TagsViewModel
    
    init() {
        _tagsViewModel = State(initialValue: TagsViewModel())
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var showCreateTagSheet = false
    
    var body: some View {
        Group {
            if tagsViewModel.loading {
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            }
            else if tagsViewModel.error {
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.circle")
                } description: {
                    Text("An error occured when loading the links data. Check your Internet connection and try again later.")
                    Button {
                        Task { await tagsViewModel.refresh(setLoading: true) }
                    } label: {
                        Label("Retry", systemImage: "arrow.counterclockwise")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
            else if tagsViewModel.data.isEmpty && tagsViewModel.searchQueryValue == nil {
                ContentUnavailableView {
                    Label("No tags created", systemImage: "tag")
                } description: {
                    Text("Add tags to links to see them here.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
            else if tagsViewModel.data.isEmpty && tagsViewModel.searchQueryValue != nil {
                ContentUnavailableView {
                    Label("No tags found", systemImage: "tag")
                } description: {
                    Text("Change the search term to see some tags.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
            else {
                ScrollView {
                    LazyVGrid(columns: Config.gridColumns) {
                        ForEach(tagsViewModel.data, id: \.self) { item in
                            NavigationLink {
                                LinksFilteredView(linksFilteredRequest: LinksFilteredRequest(name: item.name, mode: .tag, id: item.id))
                            } label: {
                                TagItemComponent(tag: item) { tag in
                                    tagsViewModel.deleteTag(tagId: tag.id)
                                } onEditTag: { tag in
                                    Task { await tagsViewModel.refresh(setLoading: false) }
                                }
                                .padding(6)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .onAppear {
                                tagsViewModel.loadNextPage()
                            }
                        }
                    }
                    .padding(12)
                }
            }
        }
        .navigationTitle("Tags")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                HStack {
                    Button("Refresh", systemImage: "arrow.counterclockwise") {
                        Task { await tagsViewModel.refresh(setLoading: true) }
                    }
                    Button("Create tag", systemImage: "plus") {
                        showCreateTagSheet = true
                    }
                }
            }
        }
        .searchable(text: $tagsViewModel.searchFieldValue)
        .onSubmit(of: .search) {
            tagsViewModel.search()
        }
        .sheet(isPresented: $showCreateTagSheet) {
            TagFormView(mode: .create) {
                showCreateTagSheet = false
            } onSuccess: {
                showCreateTagSheet = false
                Task { await tagsViewModel.refresh(setLoading: false) }
            }
        }
        .task {
            await tagsViewModel.initialLoad()
        }
        .environment(tagsViewModel)
    }
}
