import SwiftUI
import CustomAlert

struct LinksView: View {    
    @State private var linksViewModel: LinksViewModel
    
    init() {
        _linksViewModel = State(initialValue: LinksViewModel())
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var linkFormUrlSheet = false
    @State private var linkFormFileSheet = false
    
    var body: some View {
        NavigationStack {
            Group {
                if linksViewModel.loading == true {
                    ProgressView("Loading...")
                        .transition(.opacity)
                }
                else if linksViewModel.error == true {
                    ContentUnavailableView("Error", systemImage: "exclamationmark.circle", description: Text("An error occured when loading the dashboard data. Check your Internet connection and try again later."))
                    .transition(.opacity)
                }
                else {
                    Group {
                        if linksViewModel.data.isEmpty {
                            ContentUnavailableView {
                                Label("No links added", systemImage: "link")
                            } description: {
                                Text("Save some links on Linkwarden to see them here.")
                            }
                            .transition(.opacity)
                        }
                        else {
                            if horizontalSizeClass == .regular {
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
                                        .padding(.horizontal, 12)
                                    }
                                })
                            }
                            else {
                                ScrollViewReader { scrollView in
                                    List(linksViewModel.data, id: \.self) { item in
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
                                    }
                                    .animation(.default, value: linksViewModel.data)
                                    .onChange(of: linksViewModel.scrollTopList, initial: false) {
                                        guard let first = linksViewModel.data.first else { return }
                                        scrollView.scrollTo(first)
                                    }
                                }
                            }
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
                        Menu {
                            Button {
                                linkFormUrlSheet.toggle()
                            } label: {
                                Label("New link", systemImage: "link")
                            }
                            Button {
                                linkFormFileSheet.toggle()
                            } label: {
                                Label("Upload file", systemImage: "doc")
                            }
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
            .onChange(of: linksViewModel.searchPresented, { oldValue, newValue in
                if oldValue == true && newValue == false {
                    linksViewModel.clearSearch()
                }
            })
            .sheet(isPresented: $linkFormUrlSheet, content: {
                LinkFormView(mode: .url) {
                    linkFormUrlSheet = false
                } onSuccess: { newLink, action in
                    linkFormUrlSheet = false
                    linksViewModel.handleCreatedLink(link: newLink)
                }
            })
            .sheet(isPresented: $linkFormFileSheet, content: {
                LinkFormView(mode: .file) {
                    linkFormFileSheet = false
                } onSuccess: { newLink, _ in
                    linkFormFileSheet = false
                    linksViewModel.handleCreatedLink(link: newLink)
                }
            })
            .alert("Error", isPresented: $linksViewModel.deleteLinkErrorAlert) {
                Button("OK", role: .cancel) {
                    linksViewModel.deleteLinkErrorAlert = false
                }
            } message: {
                Text("An error occured when deleting the link. Try again later.")
            }
        }
        .task {
            await linksViewModel.loadData()
        }
    }
}
