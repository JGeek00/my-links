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
                Task { await tagsViewModel.refresh()}
            },
            onDeleteTag: { tag in
                tagsViewModel.deleteTag(tagId: tag.id)
            },
            onEditTag: { tag in
                tagsViewModel.handleEditTag(tag: tag)
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
            await tagsViewModel.refresh()
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
            TagFormView(mode: .create) {
                showCreateTagSheet = false
            } onSuccess: { tag in
                showCreateTagSheet = false
                Task { await tagsViewModel.refresh(setLoading: false) }
            }
        }
        .alert("Error", isPresented: $tagsViewModel.deleteTagErrorAlert) {
            Button("OK", role: .cancel) {
                tagsViewModel.deleteTagErrorAlert = false
            }
        } message: {
            Text("An error occured while deleting the tag. Please try again.")
        }
        .task {
            await tagsViewModel.initialLoad()
        }
        .environment(tagsViewModel)
    }
}
