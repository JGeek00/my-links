import SwiftUI

struct RootView: View {
    @EnvironmentObject private var onboardingViewModel: OnboardingViewModel
    @EnvironmentObject private var apiClientProvider: ApiClientProvider
    
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
                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gear")
                        }
                }
            }
        }
        .fontDesign(.rounded)
        .onAppear(perform: {
            onboardingViewModel.checkInstance()
        })
        .fullScreenCover(isPresented: $onboardingViewModel.showOnboarding, content: {
            OnboardingView()
        })
        .onChange(of: onboardingViewModel.showOnboarding) {
            onboardingViewModel.reset()
        }
    }
}
