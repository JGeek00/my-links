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
            case .success(let data):
                let searched = searchText != "" ? data.tags.filter() { $0.name.lowercased().contains(searchText.lowercased()) } : data.tags
                if data.tags.isEmpty {
                    ContentUnavailableView {
                        Label("No tags created", systemImage: "tag")
                    } description: {
                        Text("Add tags to links to see them here.")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if searched.isEmpty {
                    if searched.isEmpty {
                        ContentUnavailableView {
                            Label("No tags found", systemImage: "tag")
                        } description: {
                            Text("Change the search term to see some tags.")
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
                else {
                    if horizontalSizeClass == .regular {
                        ScrollView {
                            LazyVGrid(columns: Config.gridColumns) {
                                ForEach(searched, id: \.self) { item in
                                    TagItemComponent(tag: item)
                                        .padding(6)
                                }
                            }
                            .padding(.horizontal, 12)
                        }
                    }
                    else {
                        List(searched, id: \.self) { item in
                            TagItemComponent(tag: item)
                        }
                        .animation(.default, value: searched)
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
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
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
