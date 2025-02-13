//
//  SettingsWindowController.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 11.02.25.
//

import SwiftUI
import Cocoa

/// A custom window for the settings panel.
class SettingsWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

/// Controller responsible for managing the settings window.
class SettingsWindowController: NSWindowController, NSWindowDelegate {
    static var shared: SettingsWindowController?

    /// Initializes the controller with a given SettingsViewModel.
    /// - Parameter viewModel: The ViewModel for settings.
    init(viewModel: SettingsViewModel) {
        let settingsView = SettingsView(viewModel: viewModel)
        let hostingController = NSHostingController(rootView: settingsView)

        let windowWidth: CGFloat = 400
        let windowHeight: CGFloat = 250

        let window = SettingsWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight),
            styleMask: [.borderless],
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
        
        // Apply rounded corners
              window.contentView?.wantsLayer = true
              window.contentView?.layer?.cornerRadius = 16
              window.contentView?.layer?.masksToBounds = true

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

    /// Closes the settings window and removes the instance reference.
    func closeWindow() {
        self.window?.close()
        self.window = nil
        AppDelegate.instance.settingsWindowController = nil
    }

    /// Automatically closes the window when focus is lost.
    func windowDidResignKey(_ notification: Notification) {
        closeWindow()
    }
}
