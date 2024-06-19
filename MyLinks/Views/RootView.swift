import SwiftUI

struct RootView: View {
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    @EnvironmentObject private var apiClientProvider: ApiClientProvider
    @EnvironmentObject private var linkFormViewModel: LinkFormViewModel
    @EnvironmentObject private var collectionFormViewModel: CollectionFormViewModel
    
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
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
                .onAppear(perform: {
                    if collectionsProvider.data == nil {
                        collectionsProvider.loadData()
                    }
                    if tagsProvider.data == nil {
                        tagsProvider.loadData()
                    }
                })
                .sheet(isPresented: $linkFormViewModel.sheetOpen, content: {
                    LinkFormView()
                })
                .sheet(isPresented: $collectionFormViewModel.sheetOpen, content: {
                    CollectionFormView()
                })
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
