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
    
    var body: some View {
        Group {
            if !instances.isEmpty && apiClientProvider.instance != nil {
                NavigationSplitView {
                    Sidebar() { selection in
                        selectedView = selection
                    }
                    .navigationSplitViewColumnWidth(min: 250, ideal: 250, max: 300)
                    
                } detail: {
                    DashboardView()
                        .navigationTitle("Dashboard")
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
