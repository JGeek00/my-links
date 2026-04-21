import SwiftUI
import AlertToast

struct RootView: View {
    @State private var onboardingViewModel: OnboardingViewModel
    @State private var rootViewModel: RootViewModel
    
    init() {
        _onboardingViewModel = State(initialValue: OnboardingViewModel())
        _rootViewModel = State(initialValue: RootViewModel())
    }
    
    @AppStorage(StorageKeys.theme, store: UserDefaults.shared) private var theme: Enums.Theme = .system
    
    @Environment(\.colorScheme) private var colorScheme
    
    @FetchRequest(
        entity: ServerInstance.entity(),
        sortDescriptors: []
    ) private var instances: FetchedResults<ServerInstance>
        
    var body: some View {
        Group {
            if !instances.isEmpty && rootViewModel.apiClientInstance != nil {
                NavigationSplitView {
                    Sidebar()
                        .navigationSplitViewColumnWidth(min: 250, ideal: 250, max: 300)
                    
                } detail: {
                    DashboardView()
                        .navigationTitle("Dashboard")
                }
                .task {
                    rootViewModel.fetchCollections()
                }
            }
        }
        .fontDesign(.rounded)
        .preferredColorScheme(getColorScheme(theme: theme))
        .onAppear(perform: {
            onboardingViewModel.checkInstance()
        })
        .toast(isPresenting: $rootViewModel.toastPresenting, duration: 2, tapToDismiss: true) {
            rootViewModel.toast ?? AlertToast(type: .regular)
        }
        .sheet(isPresented: $onboardingViewModel.showOnboarding, content: {
            ConnectionForm()
                .interactiveDismissDisabled()
        })
        .onChange(of: onboardingViewModel.showOnboarding) {
            onboardingViewModel.reset()
        }
        .environment(rootViewModel)
        .environment(onboardingViewModel)
    }
}
