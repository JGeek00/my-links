import AppKit
import SwiftUI

@MainActor
class StatusBarController {
    private var statusBar: NSStatusBar
    private(set) var statusItem: NSStatusItem
    private(set) var popover: NSPopover
    
    private var onOpen: () -> Void
    private var onClose: () -> Void
        
    init (_ popover: NSPopover, onOpen: @escaping () -> Void, onClose: @escaping () -> Void) {
        self.popover = popover
        self.onOpen = onOpen
        self.onClose = onClose
        statusBar = .init()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "link", accessibilityDescription: "Create a link on My Links")
            button.action = #selector(showApp(sender:))
            button.target = self
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(popoverWillShow), name: NSPopover.willShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(popoverDidClose), name: NSPopover.didCloseNotification, object: nil)
    }
    
    
    @objc
    func showApp(sender: AnyObject) {
        if popover.isShown {
            popover.performClose(nil)
            NSApp.setActivationPolicy(.regular)
        } else {
            guard let button = statusItem.button else { return }
            popover.show(relativeTo: statusItem.button!.bounds, of: button, preferredEdge: .maxY)
        }
    }
    
    @objc
    func popoverWillShow(_ notification: Notification) {
        onOpen()
    }
    
    @objc
    func popoverDidClose(_ notification: Notification) {
        onClose()
    }
    
    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self, name: NSPopover.willShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSPopover.didCloseNotification, object: nil)
    }
}
