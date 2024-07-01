import SwiftUI
import Sentry

@main
struct MyLinksApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    let persistenceController = PersistenceController.shared
    
    init() {
        #if RELEASE
        SentrySDK.start { options in
            options.dsn = Config.sentryDsn
            options.debug = false
            options.enableTracing = false
        }
        #endif
        UserDefaults.standard.set(false, forKey: "NSFullScreenMenuItemEverywhere")
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
                .onAppear {
                    NSWindow.allowsAutomaticWindowTabbing = false
                    DispatchQueue.main.async {
                        NSApplication.shared.windows.forEach { window in
                            window.standardWindowButton(.zoomButton)?.isEnabled = false
                        }
                    }
                }
        }
        .commands {
            CommandGroup(replacing: .undoRedo) { }
            CommandGroup(replacing: .saveItem) { }
            CommandGroup(replacing: .help) { }
            CommandGroup(replacing: .systemServices) { }
            CommandGroup(replacing: .windowList) { }
            CommandGroup(replacing: .windowArrangement) { }
            CommandGroup(replacing: .pasteboard) { }
            CommandGroup(replacing: .newItem) { }
        }
        Settings {
            SettingsView()
                .frame(width: 600, height: 600)
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
