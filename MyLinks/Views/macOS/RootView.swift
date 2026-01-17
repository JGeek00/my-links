import SwiftUI
import AlertToast

struct RootView: View {
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    @EnvironmentObject private var apiClientProvider: ApiClientProvider
    @EnvironmentObject private var linkManagerProvider: LinkManagerProvider
    @EnvironmentObject private var toastProvider: ToastProvider
    
    let collectionsProvider = CollectionsProvider.shared
    let tagsProvider = TagsProvider.shared
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    
    @Environment(\.colorScheme) private var colorScheme
    
    @FetchRequest(
        entity: ServerInstance.entity(),
        sortDescriptors: []
    ) private var instances: FetchedResults<ServerInstance>
        
    var body: some View {
        Group {
            if !instances.isEmpty && apiClientProvider.instance != nil {
                NavigationSplitView {
                    Sidebar()
                        .navigationSplitViewColumnWidth(min: 250, ideal: 250, max: 300)
                    
                } detail: {
                    DashboardView()
                        .navigationTitle("Dashboard")
                        .environmentObject(DashboardViewModel.shared)
                }
                .onAppear(perform: {
                    Task { await collectionsProvider.loadData() }
                    Task { await tagsProvider.loadData() }
                })
                .alert("Error", isPresented: $linkManagerProvider.errorAlert) {
                    Button("Close", role: .cancel) {
                        linkManagerProvider.errorAlert.toggle()
                    }
                } message: {
                    Text(linkManagerProvider.errorMessage)
                }
            }
        }
        .fontDesign(.rounded)
        .preferredColorScheme(getColorScheme(theme: theme))
        .onAppear(perform: {
            onboardingViewModel.checkInstance()
        })
        .toast(isPresenting: $toastProvider.presenting, duration: 2, tapToDismiss: true) {
            toastProvider.toast ?? AlertToast(type: .regular)
        }
        .sheet(isPresented: $onboardingViewModel.showOnboarding, content: {
            ConnectionForm()
                .interactiveDismissDisabled()
        })
        .onChange(of: onboardingViewModel.showOnboarding) {
            onboardingViewModel.reset()
        }
        .environmentObject(collectionsProvider)
        .environmentObject(tagsProvider)
    }
}
