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
        #if os(macOS)
        WindowGroup {
            RootView()
                .frame(minWidth: 800, idealWidth: 1000, maxWidth: .infinity, minHeight: 500, idealHeight: 700, maxHeight: .infinity)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(OnboardingViewModel.shared)
                .environmentObject(ApiClientProvider.shared)
                .environmentObject(LinkManagerProvider.shared)
        }
        #else
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(OnboardingViewModel.shared)
                .environmentObject(ApiClientProvider.shared)
                .environmentObject(LinkManagerProvider.shared)
                .environmentObject(ToastProvider.shared)
        }
        #endif
    }
}
