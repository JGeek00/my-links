import SwiftUI
import CustomAlert

struct RootView: View {
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    @EnvironmentObject private var apiClientProvider: ApiClientProvider
    @EnvironmentObject private var linkFormViewModel: LinkFormViewModel
    @EnvironmentObject private var collectionFormViewModel: CollectionFormViewModel
    @EnvironmentObject private var deleteLinkProvider: DeleteLinkProvider
    
    let collectionsProvider = CollectionsProvider.shared
    let tagsProvider = TagsProvider.shared
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    
    @FetchRequest(
        entity: ServerInstance.entity(),
        sortDescriptors: []
    ) private var instances: FetchedResults<ServerInstance>
    
    var body: some View {
        Group {
            if !instances.isEmpty && apiClientProvider.instance != nil {
                TabView {
                    DashboardView()
                        .tabItem {
                            Label("Dashboard", systemImage: "house.fill")
                        }
                    LinksView()
                        .tabItem {
                            Label("Links", systemImage: "link")
                        }
                    CollectionsView()
                        .tabItem {
                            Label("Collections", systemImage: "folder")
                        }
                    TagsView()
                        .tabItem {
                            Label("Tags", systemImage: "tag")
                        }
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
                .onAppear(perform: {
                    if collectionsProvider.data == nil {
                        Task { await collectionsProvider.loadData() }
                    }
                    if tagsProvider.data == nil {
                        Task { await tagsProvider.loadData() }
                    }
                })
                .sheet(isPresented: $linkFormViewModel.sheetOpen, content: {
                    LinkFormView()
                })
                .sheet(isPresented: $collectionFormViewModel.sheetOpen, content: {
                    CollectionFormView()
                })
                .customAlert(isPresented: $deleteLinkProvider.deleting, content: {
                    ProgressView()
                })
                .alert("Error", isPresented: $deleteLinkProvider.deleteError) {
                    Button("Close", role: .cancel) {
                        deleteLinkProvider.deleteError.toggle()
                    }
                } message: {
                    Text("The link could not be deleted due to an error.")
                }
            }
        }
        .fontDesign(.rounded)
        .preferredColorScheme(getColorScheme(theme: theme))
        .onAppear(perform: {
            onboardingViewModel.checkInstance()
            requestAppReview()
        })
        .fullScreenCover(isPresented: $onboardingViewModel.showOnboarding, content: {
            OnboardingView()
        })
        .onChange(of: onboardingViewModel.showOnboarding) {
            onboardingViewModel.reset()
        }
        .environmentObject(collectionsProvider)
        .environmentObject(tagsProvider)
    }
}
