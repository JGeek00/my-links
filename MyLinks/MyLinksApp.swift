import SwiftUI

@main
struct MyLinksApp: App {
    let persistenceController = PersistenceController.shared
    
    let onboardingViewModel = OnboardingViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(onboardingViewModel)
                .environmentObject(ApiClientProvider.shared)
        }
    }
}
