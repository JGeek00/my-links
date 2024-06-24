import SwiftUI

struct LinksFilteredView: View {
    var input: LinksFilteredRequest
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @StateObject private var linksFilteredViewModel: LinksFilteredViewModel
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    
    init(input: LinksFilteredRequest) {
        self.input = input
        _linksFilteredViewModel = StateObject(wrappedValue: LinksFilteredViewModel(input: input))
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
                    if horizontalSizeClass == .regular {
                        ScrollViewReader(content: { scrollView in
                            ScrollView {
                                LazyVGrid(columns: Config.gridColumns) {
                                    ForEach(filtered, id: \.self) { item in
                                        LinkItemComponent(item: item) {
                                            openSafariView(item.url!)
                                        } onTaskCompleted: { link, action in
                                            linksFilteredViewModel.onTaskCompleted(link: link, action: action)
                                        }
                                        .onAppear {
                                            if item == filtered.last {
                                                linksFilteredViewModel.loadMore()
                                            }
                                        }
                                        .padding(6)
                                    }
                                }
                                .padding(.horizontal, 12)
                            }
                        })
                    }
                    else {
                        ScrollViewReader { scrollView in
                            List(filtered, id: \.self) { item in
                                LinkItemComponent(item: item) {
                                    openSafariView(item.url!)
                                } onTaskCompleted: { link, action in
                                    linksFilteredViewModel.onTaskCompleted(link: link, action: action)
                                }
                                .onAppear {
                                    if item == filtered.last {
                                        linksFilteredViewModel.loadMore()
                                    }
                                }
                            }
                            .animation(.default, value: filtered)
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("", selection: $linksFilteredViewModel.sortingSelected) {
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
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                .disabled(linksFilteredViewModel.loading)
            }
        }
        .background(Color.listBackground)
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
