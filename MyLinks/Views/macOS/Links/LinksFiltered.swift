import SwiftUI

struct LinksFilteredView: View {
    var input: LinksFilteredRequest
    
    @StateObject private var linksFilteredViewModel: LinksFilteredViewModel
    
    init(input: LinksFilteredRequest) {
        self.input = input
        _linksFilteredViewModel = StateObject(wrappedValue: LinksFilteredViewModel(input: input))
    }
    
    @State private var linkFormSheet = false
    
    var body: some View {
        Group {
            if linksFilteredViewModel.loading == true {
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
                    ScrollViewReader(content: { scrollView in
                        ScrollView {
                            LazyVGrid(columns: Config.gridColumns) {
                                ForEach(filtered, id: \.self) { item in
                                    LinkItemComponent(item: item)
                                    .onAppear {
                                        if item == filtered.last {
                                            linksFilteredViewModel.loadMore()
                                        }
                                    }
                                    .padding(6)
                                }
                            }
                            .padding(12)
                        }
                    })
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
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Picker("Sort", systemImage: "arrow.up.arrow.down", selection: $linksFilteredViewModel.sortingSelected) {
                    Text("Date (newest first)")
                        .tag(Enums.SortingOptions.dateNewestFirst)
                    Text("Date (oldest first)")
                        .tag(Enums.SortingOptions.dateOldestFirst)
                    Text("Name (A-Z)")
                        .tag(Enums.SortingOptions.nameAZ)
                    Text("Name (Z-A)")
                        .tag(Enums.SortingOptions.nameZA)
                    Text("Description (A-Z)")
                        .tag(Enums.SortingOptions.descriptionAZ)
                    Text("Description (Z-A)")
                        .tag(Enums.SortingOptions.descriptionZA)
                }
                .onChange(of: linksFilteredViewModel.sortingSelected, initial: false) {
                    Task { await linksFilteredViewModel.loadData(setLoading: true) }
                }
                .disabled(linksFilteredViewModel.loading)
            }
        }
        .refreshable {
            await linksFilteredViewModel.loadData()
        }
        .searchable(text: $linksFilteredViewModel.searchFieldValue, isPresented: $linksFilteredViewModel.searchPresented)
        .onSubmit(of: .search) {
            linksFilteredViewModel.search()
        }
        .sheet(isPresented: $linkFormSheet, content: {
            LinkFormView() {
                linkFormSheet = false
            } onSuccess: { newLink, action in
                linkFormSheet = false
            }
            .environmentObject(LinkFormViewModel())
        })
        .onChange(of: linksFilteredViewModel.searchPresented, { oldValue, newValue in
            if oldValue == true && newValue == false {
                linksFilteredViewModel.clearSearch()
            }
        })
        .onAppear(perform: {
            if linksFilteredViewModel.data.isEmpty {
                Task { await linksFilteredViewModel.loadData() }
            }
        })
    }
}
