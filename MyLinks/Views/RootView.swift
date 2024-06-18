import SwiftUI

struct RootView: View {
    @EnvironmentObject private var instanceViewModel: InstanceViewModel
    
    @FetchRequest(
        entity: Instance.entity(),
        sortDescriptors: []
    ) private var instances: FetchedResults<Instance>
    
    var body: some View {
        Group {
            if !instances.isEmpty {
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
            instanceViewModel.checkInstance()
        })
        .fullScreenCover(isPresented: $instanceViewModel.showOnboarding, content: {
            OnboardingView()
                .environmentObject(OnboardingViewModel())
        })
    }
}
