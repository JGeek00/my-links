import SwiftUI

struct CollectionOrTagLinksView: View {
    var input: CollectionOrTagLinksRequest
    
    init(input: CollectionOrTagLinksRequest) {
        self.input = input
        CollectionOrTagsLinksViewModel.shared.input = input
    }
    
    @EnvironmentObject private var collectionOrTagLinksViewModel: CollectionOrTagsLinksViewModel
    
    var body: some View {
        Group {
            if input.tagId == nil && input.collectionId == nil {
                ContentUnavailableView {
                    Label("404", systemImage: "exclamationmark.circle")
                } description: {
                    Text("Requested links not found.")
                }
            }
            else if collectionOrTagLinksViewModel.loading == true {
                Group {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if collectionOrTagLinksViewModel.error == true {
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.circle")
                } description: {
                    Text("An error occured when loading the links data. Check your Internet connection and try again later.")
                    Button {
                        Task { await collectionOrTagLinksViewModel.loadData(setLoading: true) }
                    } label: {
                        Label("Retry", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            else {
                let filtered = collectionOrTagLinksViewModel.data?.response?.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.url != nil && $0.tags != nil && $0.collection?.id != nil } ?? []
                if !filtered.isEmpty {
                    List(filtered, id: \.self) { item in
                        LinkItemComponent(item: item, fromCollectionOrTagLinkView: true) {
                            openSafariView(item.url!)
                        }
                    }
                }
                else {
                    ContentUnavailableView {
                        Label("No links added", systemImage: "link")
                    } description: {
                        Text("Save some links on Linkwarden to see them here.")
                    }
                }
            }
        }
        .navigationTitle(input.name)
        .refreshable {
            await collectionOrTagLinksViewModel.loadData()
        }
        .background(Color.listBackground)
        .onAppear(perform: {
            if collectionOrTagLinksViewModel.data == nil && (input.collectionId != nil || input.tagId != nil) {
                Task { await collectionOrTagLinksViewModel.loadData() }
            }
        })
    }
}
