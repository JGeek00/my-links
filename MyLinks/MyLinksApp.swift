import SwiftUI
import Sentry

@main
struct MyLinksApp: App {
    let persistenceController = PersistenceController.shared
    
    init() {
        #if RELEASE
        SentrySDK.start { options in
            options.dsn = Config.sentryDsn
            options.debug = false
            options.enableTracing = false
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(OnboardingViewModel.shared)
                .environmentObject(ApiClientProvider.shared)
                .environmentObject(CollectionFormViewModel.shared)
                .environmentObject(LinkManagerProvider.shared)
                .environmentObject(ToastProvider.shared)
        }
    }
}
