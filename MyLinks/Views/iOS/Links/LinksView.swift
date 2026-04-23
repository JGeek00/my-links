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
            LinksList(
                loading: linksViewModel.loading,
                error: linksViewModel.error,
                withSearch: linksViewModel.searchQueryValue != nil,
                data: linksViewModel.data,
                scrollToTop: linksViewModel.scrollTopList,
                onEditLink: { link in
                    linksViewModel.handleEditLink(link: link)
                },
                onDeleteLink: { link in
                    linksViewModel.handleDeleteLink(linkId: link.id)
                },
                onLoadMore: {
                    linksViewModel.loadMore()
                },
                onReload: {
                    Task { await linksViewModel.loadInitial() }
                }
            )
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
                                Task { await linksViewModel.loadInitial() }
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
                await linksViewModel.refresh()
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
            await linksViewModel.loadInitial()
        }
    }
}
