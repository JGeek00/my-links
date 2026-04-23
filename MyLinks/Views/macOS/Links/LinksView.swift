import SwiftUI

struct LinksView: View {
    @State private var linksViewModel: LinksViewModel
    
    init() {
        _linksViewModel = State(initialValue: LinksViewModel())
    }

    @State private var linkFormUrlSheet = false
    @State private var linkFormFileSheet = false
    
    var body: some View {
        Group {
            if linksViewModel.loading == true {
                Group {
                    ProgressView()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
            else if linksViewModel.error == true {
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.circle")
                } description: {
                    Text("An error occured when loading the links data. Check your Internet connection and try again later.")
                    Button {
                        Task { await linksViewModel.refresh(setLoading: true) }
                    } label: {
                        Label("Retry", systemImage: "arrow.counterclockwise")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
            else if linksViewModel.data.isEmpty && linksViewModel.searchQueryValue == nil {
                ContentUnavailableView {
                    Label("No links added", systemImage: "link")
                } description: {
                    Text("Save some links on Linkwarden to see them here.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
            else if linksViewModel.data.isEmpty && linksViewModel.searchQueryValue != nil {
                ContentUnavailableView {
                    Label("No links found", systemImage: "magnifyingglass")
                } description: {
                    Text("Change the search term to see some links.")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
            }
            else {
                ScrollViewReader(content: { scrollView in
                    ScrollView {
                        LazyVGrid(columns: Config.gridColumns) {
                            ForEach(linksViewModel.data, id: \.self) { item in
                                LinkItemComponent(item: item) { l, id, action in
                                    switch action {
                                    case .edit:
                                        linksViewModel.handleEditLink(link: l!)
                                    case .delete:
                                        linksViewModel.handleDeleteLink(linkId: id!)
                                    }
                                }
                                .onAppear {
                                    if item == linksViewModel.data.last {
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
        }
        .navigationTitle("Links")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                HStack {
                    Button {
                        Task { await linksViewModel.refresh(setLoading: true) }
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
                        Task { await linksViewModel.refresh(setLoading: true) }
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
            LinkFormView(mode: Enums.LinkFormItem.url) {
                linkFormUrlSheet = false
            } onSuccess: { newLink, action in
                linkFormUrlSheet = false
                linksViewModel.handleCreatedLink(link: newLink)
            }
        })
        .sheet(isPresented: $linkFormFileSheet, content: {
            LinkFormView(mode: Enums.LinkFormItem.url) {
                linkFormFileSheet = false
            } onSuccess: { newLink, _ in
                linkFormFileSheet = false
                linksViewModel.handleCreatedLink(link: newLink)
            }
        })
        .onChange(of: linksViewModel.searchPresented, { oldValue, newValue in
            if oldValue == true && newValue == false {
                linksViewModel.clearSearch()
            }
        })
        .task {
            await linksViewModel.loadInitial()
        }
    }
}
