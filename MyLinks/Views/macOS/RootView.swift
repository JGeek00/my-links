import SwiftUI

struct RootView: View {
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    @EnvironmentObject private var apiClientProvider: ApiClientProvider
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    
    let collectionsProvider = CollectionsProvider.shared
    let tagsProvider = TagsProvider.shared
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    
    @Environment(\.colorScheme) private var colorScheme
    
    @FetchRequest(
        entity: ServerInstance.entity(),
        sortDescriptors: []
    ) private var instances: FetchedResults<ServerInstance>
    
    @State private var selectedView = Enums.DashboardView.dashboard    
    @State private var linkFormSheet = false
    @State private var collectionFormSheet = false
    
    var body: some View {
        Group {
            if !instances.isEmpty && apiClientProvider.instance != nil {
                NavigationSplitView {
                    Sidebar() { selection in
                        selectedView = selection
                    }
                    .navigationSplitViewColumnWidth(min: 250, ideal: 250, max: 300)
                    
                } detail: {
                    Group {
                        switch selectedView {
                        case .dashboard:
                            DashboardView(viewAllLinks: {
                                selectedView = .links
                            }, viewPinned: {
                                selectedView = .pinned
                            })
                            .navigationTitle("Dashboard")
                        case .links:
                            LinksView()
                                .navigationTitle("Links")
                        case .pinned:
                            LinksView()
                                .navigationTitle("Pinned")
                        case .collections:
                            CollectionsView()
                                .navigationTitle("Collections")
                        }
                    }
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            Menu {
                                Button {
                                    linkFormSheet.toggle()
                                } label: {
                                    Label("New link", systemImage: "link")
                                }
                                Button {
                                    collectionFormSheet = true
                                } label: {
                                    Label("New collection", systemImage: "folder")
                                }
                            } label: {
                                Image(systemName: "plus")
                            }
                        }
                    }
                    .sheet(isPresented: $linkFormSheet, content: {
                        LinkFormView() {
                            linkFormSheet = false
                        } onSuccess: { newLink, action in
                            linkFormSheet = false
                        }
                        .environmentObject(LinkFormViewModel())
                    })
                    .sheet(isPresented: $collectionFormSheet, content: {
                        CollectionFormView() {
                            collectionFormSheet = false
                        } onSuccess: { item, action in
                            collectionFormSheet = false
                        }
                        .environmentObject(CollectionFormViewModel())
                    })
                }
                .onAppear(perform: {
                    if collectionsProvider.data.isEmpty {
                        Task { await collectionsProvider.loadData() }
                    }
                    if tagsProvider.data.isEmpty {
                        Task { await tagsProvider.loadData() }
                    }
                })
                .alert("Error", isPresented: $linkManagerProvider.errorAlert) {
                    Button("Close", role: .cancel) {
                        linkManagerProvider.errorAlert.toggle()
                    }
                } message: {
                    Text(linkManagerProvider.errorMessage)
                }
            }
            else {
                ConnectionForm()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .fontDesign(.rounded)
        .preferredColorScheme(getColorScheme(theme: theme))
        .onAppear(perform: {
            onboardingViewModel.checkInstance()
            #if os(iOS)
            requestAppReview()
            #endif
        })
        .onChange(of: onboardingViewModel.showOnboarding) {
            onboardingViewModel.reset()
        }
        .environmentObject(collectionsProvider)
        .environmentObject(tagsProvider)
    }
}
