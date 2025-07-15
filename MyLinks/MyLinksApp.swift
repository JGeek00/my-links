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
        WindowGroup(id: WindowIds.main) {
            RootView()
                .frame(minWidth: 800, idealWidth: 1000, maxWidth: .infinity, minHeight: 500, idealHeight: 700, maxHeight: .infinity)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(OnboardingViewModel.shared)
                .environmentObject(ApiClientProvider.shared)
                .environmentObject(LinkManagerProvider.shared)
                .environmentObject(ToastProvider.shared)
                .onAppear {
                    NSApp.setActivationPolicy(.regular)
                    NSWindow.allowsAutomaticWindowTabbing = false
                    DispatchQueue.main.async {
                        NSApplication.shared.windows.forEach { window in
                            window.standardWindowButton(.zoomButton)?.isEnabled = false
                        }
                    }
                }
                .onDisappear {
                    guard let windows = NSApplication.shared.windows as [NSWindow]? else { return }
                    for window in windows {
                        if window.identifier?.rawValue == "com_apple_SwiftUI_Settings_window" {
                            window.close()
                            break
                        }
                    }
                    let filtered = NSApplication.shared.windows.filter() { $0.identifier?.rawValue != nil && $0.identifier?.rawValue != "com_apple_SwiftUI_Settings_window" }
                    if filtered.count < 2 {
                        NSApp.setActivationPolicy(.accessory)
                    }
                }
        }
        .defaultSize(width: 1200, height: 700)
        Settings {
            SettingsView()
                .frame(width: 600, height: 600)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(OnboardingViewModel.shared)
                .environmentObject(ApiClientProvider.shared)
                .environmentObject(LinkManagerProvider.shared)
                .environmentObject(IAPManager())
        }
        #else
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(OnboardingViewModel.shared)
                .environmentObject(ApiClientProvider.shared)
                .environmentObject(LinkManagerProvider.shared)
                .environmentObject(ToastProvider.shared)
                .environmentObject(IAPManager())
                .environmentObject(SearchViewModel())
        }
        #endif
    }
}
