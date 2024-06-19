import SwiftUI

struct LinksView: View {
    @StateObject private var linksViewModel = LinksViewModel()
    @EnvironmentObject private var linkFormViewModel: LinkFormViewModel
    
    init() {}
    
    var body: some View {
        NavigationStack {
            Group {
                if linksViewModel.loading == true {
                    ProgressView()
                }
                else if linksViewModel.error == true {
                    ContentUnavailableView {
                        Label("Error", systemImage: "exclamationmark.circle")
                    } description: {
                        Text("An error occured when loading the links data. Check your Internet connection and try again later.")
                        Button {
                            linksViewModel.loadData(setLoading: true)
                        } label: {
                            Label("Retry", systemImage: "arrow.counterclockwise")
                        }
                    }
                }
                else {
                    let filtered = linksViewModel.data?.response?.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.url != nil && $0.tags != nil && $0.collection?.id != nil }
                    List(filtered ?? [], id: \.self) { item in
                        LinkItemComponent(item: item) {
                            openSafariView(item.url!)
                        }
                    }
                }
            }
            .navigationTitle("Links")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        linkFormViewModel.sheetOpen = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .refreshable {
                linksViewModel.loadData()
            }
        }
    }
}
