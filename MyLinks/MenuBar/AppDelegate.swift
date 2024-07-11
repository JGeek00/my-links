import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    static var popover = NSPopover()
    var statusBar: StatusBarController?
    
    private var popoverState = PopoverState()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        if let items = NSApp.mainMenu?.items {
            items.suffix(from: 3).forEach { item in
                NSApp.mainMenu?.removeItem(item)
            }
        }
        
        Self.popover.contentViewController = NSHostingController(
            rootView: PopoverView()
                .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
                .environmentObject(popoverState)
        )
        Self.popover.behavior = .transient
        Self.popover.contentSize = NSSize(width: 400, height: 400)
        statusBar = StatusBarController(Self.popover, popoverState: popoverState)
    }
}

class PopoverState: ObservableObject {
    @Published var isPopoverOpen = false
}
