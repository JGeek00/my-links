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
        TagsList(
            loading: tagsViewModel.loading,
            error: tagsViewModel.error,
            withSearch: tagsViewModel.searchQueryValue != nil,
            data: tagsViewModel.data,
            onReload: {
                Task { await tagsViewModel.loadData()}
            },
            onDeleteTag: { tag in
                Task { await tagsViewModel.deleteTag(tagId: tag.id) }
            },
            onLoadNextBatch: {
                tagsViewModel.loadNextPage()
            }
        )
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
