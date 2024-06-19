import SwiftUI
import CustomAlert

struct TagsView: View {
    @EnvironmentObject private var tagsProvider: TagsProvider
    
    init() {}
    
    var body: some View {
        NavigationStack {
            Group {
                if tagsProvider.loading == true {
                    Group {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                else if tagsProvider.error == true {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.circle")
                    } description: {
                        Text("An error occured when loading the links data. Check your Internet connection and try again later.")
                        Button {
                            Task { await tagsProvider.loadData(setLoading: true) }
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                else {
                    let filtered = tagsProvider.data?.response?.filter() { $0.id != nil && $0.name != nil && $0.createdAt != nil } ?? []
                    if !filtered.isEmpty {
                        List(filtered, id: \.self) { item in
                            TagItemComponent(tag: item) {
                                
                            }
                        }
                    }
                    else {
                        ContentUnavailableView {
                            Label("No tags created", systemImage: "tag")
                        } description: {
                            Text("Add tags to links to see them here.")
                        }
                    }
                }
            }
            .navigationTitle("Tags")
            .refreshable {
                await tagsProvider.loadData()
            }
            .background(Color.listBackground)
        }
    }
}
