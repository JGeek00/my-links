import SwiftUI
import CustomAlert

struct TagsView: View {
    @State private var tagsViewModel: TagsViewModel
    
    init() {
        _tagsViewModel = State(initialValue: TagsViewModel())
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    @State private var searchText = ""
    @State private var showCreateTagSheet = false
    
    var body: some View {
        Group {
            switch tagsViewModel.state {
            case .loading:
                ProgressView("Loading...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
            case .success(let data):
                if data.tags.isEmpty && searchText != "" {
                    ContentUnavailableView {
                        Label("No tags found", systemImage: "tag")
                    } description: {
                        Text("Change the search term to see some tags.")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.opacity)
                }
                else if data.tags.isEmpty && searchText == "" {
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
                                ForEach(data.tags, id: \.self) { item in
                                    TagItemComponent(tag: item) {
                                        Task {
                                            await tagsViewModel.deleteTag(tagId: item.id)
                                        }
                                    }
                                    .padding(6)
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                        .transition(.opacity)
                    }
                    else {
                        List(data.tags, id: \.self) { item in
                            TagItemComponent(tag: item) {
                                Task {
                                    await tagsViewModel.deleteTag(tagId: item.id)
                                }
                            }
                        }
                        .animation(.default, value: data.tags)
                        .transition(.opacity)
                    }
                }

            case .failure:
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.circle")
                } description: {
                    Text("An error occured when loading the links data. Check your Internet connection and try again later.")
                    Button {
                        Task { await tagsViewModel.loadData(setLoading: true) }
                    } label: {
                        Label("Retry", systemImage: "arrow.counterclockwise")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .navigationTitle("Tags")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Create tag", systemImage: "plus") {
                    showCreateTagSheet = true
                }
            }
        }
        .refreshable {
            await tagsViewModel.loadData()
        }
        .searchable(text: $tagsViewModel.searchFieldValue, isPresented: $tagsViewModel.searchPresented, placement: .navigationBarDrawer(displayMode: .always))
        .onSubmit(of: .search) {
            tagsViewModel.search()
        }
        .onChange(of: tagsViewModel.searchPresented, { oldValue, newValue in
            if oldValue == true && newValue == false {
                tagsViewModel.clearSearch()
            }
        })
        .sheet(isPresented: $showCreateTagSheet) {
            TagFormView {
                showCreateTagSheet = false
            }
        }
        .task {
            await tagsViewModel.loadData()
        }
        .environment(tagsViewModel)
    }
}
