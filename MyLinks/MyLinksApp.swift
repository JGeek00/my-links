import SwiftUI

@main
struct MyLinksApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(OnboardingViewModel.shared)
                .environmentObject(ApiClientProvider.shared)
                .environmentObject(LinkFormViewModel.shared)
                .environmentObject(CollectionFormViewModel.shared)
        }
    }
}
