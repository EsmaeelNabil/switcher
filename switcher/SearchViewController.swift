import SwiftUI

class SearchWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

class SearchWindowController: NSWindowController, NSWindowDelegate {
    static var shared: SearchWindowController?

    init(model: SearchModel) {
        let searchView = SearchPopupView(model: model)
        let hostingController = NSHostingController(rootView: searchView)

        let windowWidth: CGFloat = 400
        let windowHeight: CGFloat = 250

        let window = SearchWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .fullSizeContentView], // Frameless but key window
            backing: .buffered,
            defer: false
        )

        window.contentViewController = hostingController
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.hasShadow = true
        window.isMovableByWindowBackground = true // Allow dragging
        
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true

        // Get primary screen size and center the window
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame // Avoid Dock/Menu Bar overlap
            let centerX = screenFrame.origin.x + (screenFrame.width - windowWidth) / 2
            let centerY = screenFrame.origin.y + (screenFrame.height - windowHeight) / 2
            window.setFrameOrigin(NSPoint(x: centerX, y: centerY))
        }

        super.init(window: window)
        window.delegate = self // Detect focus loss
        self.shouldCascadeWindows = false
        self.window?.makeKeyAndOrderFront(nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func closeWindow() {
        self.window?.close()
        self.window = nil
        AppDelegate.instance.searchWindowController = nil // Fully remove instance
    }

    // MARK: - Close on Focus Loss
    func windowDidResignKey(_ notification: Notification) {
        closeWindow() // Close and remove instance when focus is lost
    }
}
