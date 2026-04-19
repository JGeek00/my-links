import SwiftUI

struct LinksView: View {
    @StateObject private var linksViewModel = LinksViewModel.shared

    @State private var linkFormUrlSheet = false
    @State private var linkFormFileSheet = false
    
    var body: some View {
        Group {
            if linksViewModel.loading == true {
                Group {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            else if linksViewModel.error == true {
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.circle")
                } description: {
                    Text("An error occured when loading the links data. Check your Internet connection and try again later.")
                    Button {
                        Task { await linksViewModel.loadData(setLoading: true) }
                    } label: {
                        Label("Retry", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            else {
                let filtered = linksViewModel.data.filter() { $0.id != nil && $0.name != nil && $0.description != nil && $0.tags != nil && $0.collection?.id != nil }
                if !filtered.isEmpty {
                    ScrollViewReader(content: { scrollView in
                        ScrollView {
                            LazyVGrid(columns: Config.gridColumns) {
                                ForEach(filtered, id: \.self) { item in
                                    LinkItemComponent(item: item) { l, action in
                                        // TODO: handle actions
                                    }
                                    .onAppear {
                                        if item == filtered.last {
                                            linksViewModel.loadMore()
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
        .navigationTitle("Links")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                HStack {
                    Button {
                        Task { await linksViewModel.loadData(setLoading: true) }
                    } label: {
                        Image(systemName: "arrow.counterclockwise")
                    }
                    Menu("Add", systemImage: "plus") {
                        Button {
                            linkFormUrlSheet = true
                        } label: {
                            Label("New link", systemImage: "link")
                        }
                        Button {
                            linkFormFileSheet = true
                        } label: {
                            Label("Upload file", systemImage: "doc")
                        }
                    }
                    Picker("Sort", systemImage: "arrow.up.arrow.down", selection: $linksViewModel.sortingSelected) {
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
                    .onChange(of: linksViewModel.sortingSelected, initial: false) {
                        Task { await linksViewModel.loadData(setLoading: true) }
                    }
                    .disabled(linksViewModel.loading)
                }
            }
        }
        .searchable(text: $linksViewModel.searchFieldValue, isPresented: $linksViewModel.searchPresented)
        .onSubmit(of: .search) {
            linksViewModel.search()
        }
        .sheet(isPresented: $linkFormUrlSheet, content: {
            LinkFormView(mode: .url) {
                linkFormUrlSheet = false
            } onSuccess: { newLink, action in
                linkFormUrlSheet = false
            }
        })
        .sheet(isPresented: $linkFormFileSheet, content: {
            LinkFormView(mode: .file) {
                linkFormFileSheet = false
            } onSuccess: { newLink, action in
                linkFormFileSheet = false
            }
        })
        .onChange(of: linksViewModel.searchPresented, { oldValue, newValue in
            if oldValue == true && newValue == false {
                linksViewModel.clearSearch()
            }
        })
        .onAppear(perform: {
            Task { await linksViewModel.loadData() }
        })
    }
}
