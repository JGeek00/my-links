import SwiftUI

@main
struct MyLinksApp: App {
    let persistenceController = PersistenceController.shared
    
    let instanceViewModel = InstanceViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(instanceViewModel)
        }
    }
}
