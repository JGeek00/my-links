import AppKit
import SwiftUI

class StatusBarController {
    private var statusBar: NSStatusBar
    private (set) var statusItem: NSStatusItem
    private (set) var popover: NSPopover
    
    @ObservedObject var popoverState: PopoverState
    
    init (_ popover: NSPopover, popoverState: PopoverState) {
        self.popover = popover
        self.popoverState = popoverState
        statusBar = .init()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "link", accessibilityDescription: "Add link to MyLinks")
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
        popoverState.isPopoverOpen = true
    }
    
    @objc
    func popoverDidClose(_ notification: Notification) {
        popoverState.isPopoverOpen = false
    }
    
    deinit {
        // Remove observers
        NotificationCenter.default.removeObserver(self, name: NSPopover.willShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSPopover.didCloseNotification, object: nil)
    }
}
