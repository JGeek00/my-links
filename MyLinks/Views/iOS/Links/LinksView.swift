import SwiftUI
import CustomAlert

struct LinksView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @StateObject private var linksViewModel = LinksViewModel.shared
    
    init() {}
    
    @State private var linkFormSheet = false
    
    var body: some View {
        NavigationStack {
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
                        if horizontalSizeClass == .regular {
                            ScrollViewReader(content: { scrollView in
                                ScrollView {
                                    LazyVGrid(columns: Config.gridColumns) {
                                        ForEach(filtered, id: \.self) { item in
                                            LinkItemComponent(item: item) { _, _ in }
                                            .onAppear {
                                                if item == filtered.last {
                                                    linksViewModel.loadMore()
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
                                    LinkItemComponent(item: item) { _, _ in }
                                    .onAppear {
                                        if item == filtered.last {
                                            linksViewModel.loadMore()
                                        }
                                    }
                                }
                                .animation(.default, value: filtered)
                                .onChange(of: linksViewModel.scrollTopList, initial: false) {
                                    guard let first = linksViewModel.data.first else { return }
                                    scrollView.scrollTo(first)
                                }
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
            .navigationTitle("Links")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack {
                        Menu {
                            Picker("", selection: $linksViewModel.sortingSelected) {
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
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                        }
                        .disabled(linksViewModel.loading)
                        Button {
                            linkFormSheet.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
            }
            .refreshable {
                await linksViewModel.loadData()
            }
            .searchable(text: $linksViewModel.searchFieldValue, isPresented: $linksViewModel.searchPresented, placement: .navigationBarDrawer(displayMode: .always))
            .onSubmit(of: .search) {
                linksViewModel.search()
            }
            .sheet(isPresented: $linkFormSheet, content: {
                LinkFormView() {
                    linkFormSheet = false
                } onSuccess: { newLink, action in
                    linkFormSheet = false
                }
                .environmentObject(LinkFormViewModel())
            })
            .onChange(of: linksViewModel.searchPresented, { oldValue, newValue in
                if oldValue == true && newValue == false {
                    linksViewModel.clearSearch()
                }
            })
            .background(Color.listBackground)
        }
        .onAppear(perform: {
            if linksViewModel.data.isEmpty {
                Task { await linksViewModel.loadData() }
            }
        })
    }
}
