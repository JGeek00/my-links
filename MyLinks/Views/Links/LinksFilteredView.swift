import SwiftUI

struct LinksFilteredView: View {
    var input: LinksFilteredRequest
    
    @ObservedObject private var linksFilteredViewModel: LinksFilteredViewModel
    @EnvironmentObject private var linkFormViewModel: LinkFormViewModel
    
    init(input: LinksFilteredRequest) {
        self.input = input
        _linksFilteredViewModel = ObservedObject(wrappedValue: LinksFilteredViewModel(input: input))
    }
    
    var body: some View {
        Group {
            if (input.mode == .collection || input.mode == .tag) && input.id == nil {
                ContentUnavailableView {
                    Label("404", systemImage: "exclamationmark.circle")
                } description: {
                    Text("Requested links not found.")
                }
            }
            else if linksFilteredViewModel.loading == true {
                Group {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if linksFilteredViewModel.error == true {
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.circle")
                } description: {
                    Text("An error occured when loading the links data. Check your Internet connection and try again later.")
                    Button {
                        Task { await linksFilteredViewModel.loadData(setLoading: true) }
                    } label: {
                        Label("Retry", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            else {
                let filtered = linksFilteredViewModel.data.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.url != nil && $0.tags != nil && $0.collection?.id != nil }
                if !filtered.isEmpty {
                    List(filtered, id: \.self) { item in
                        LinkItemComponent(item: item) {
                            openSafariView(item.url!)
                        } onTaskCompleted: {
                            linksFilteredViewModel.reload()
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
            await linksFilteredViewModel.loadData()
        }
        .searchable(text: $linksFilteredViewModel.searchFieldValue, isPresented: $linksFilteredViewModel.searchPresented, placement: .navigationBarDrawer(displayMode: .always))
        .onSubmit(of: .search) {
            linksFilteredViewModel.search()
        }
        .onChange(of: linksFilteredViewModel.searchPresented, { oldValue, newValue in
            if oldValue == true && newValue == false {
                linksFilteredViewModel.clearSearch()
            }
        })
        .background(Color.listBackground)
        .onAppear(perform: {
            if linksFilteredViewModel.data.isEmpty {
                Task { await linksFilteredViewModel.loadData() }
            }
        })
        .onChange(of: linkFormViewModel.finishedEditingFlag) {
            // Reload the data when this flag changes
            Task { await linksFilteredViewModel.loadData() }
        }
    }
}
