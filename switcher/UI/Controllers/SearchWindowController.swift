//
//  SearchWindowController.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 11.02.25.
//

import SwiftUI
import Cocoa

/// A custom window for the search popup.
class SearchWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

/// Controller responsible for managing the search window.
class SearchWindowController: NSWindowController, NSWindowDelegate {
    static var shared: SearchWindowController?
    
    /// Initializes the controller with a given SearchViewModel.
    /// - Parameter viewModel: The view model for search.
    init(viewModel: SearchViewModel) {
        let searchView = SearchPopupView(viewModel: viewModel)
        let hostingController = NSHostingController(rootView: searchView)
        
        let windowWidth: CGFloat = 400
        let windowHeight: CGFloat = 250
        
        let window = SearchWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        window.contentViewController = hostingController
        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.hasShadow = true
        window.isMovableByWindowBackground = true
        
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        if let screen = NSScreen.main {
            let screenFrame = screen.visibleFrame
            let centerX = screenFrame.origin.x + (screenFrame.width - windowWidth) / 2
            let centerY = screenFrame.origin.y + (screenFrame.height - windowHeight) / 2
            window.setFrameOrigin(NSPoint(x: centerX, y: centerY))
        }
        
        super.init(window: window)
        window.delegate = self
        self.shouldCascadeWindows = false
        self.window?.makeKeyAndOrderFront(nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Closes the search window and clears its reference.
    func closeWindow() {
        self.window?.close()
        self.window = nil
        AppDelegate.instance.searchWindowController = nil
    }
    
    /// Automatically closes the window when focus is lost.
    func windowDidResignKey(_ notification: Notification) {
        closeWindow()
    }
}
