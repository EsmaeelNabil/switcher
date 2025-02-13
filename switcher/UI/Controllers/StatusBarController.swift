//
//  StatusBarController.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 11.02.25.
//

import Cocoa
import SwiftUI

final class StatusBarController {
    lazy var statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    weak var switcherMenuItem: NSMenuItem?
    
    init() {
        setupView()
    }
    
    private func setupView() {
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "square.on.square.dashed", accessibilityDescription: "Menu Bar Icon")
            button.target = self
            button.action = #selector(onStatusBarClick)
        }
        statusItem.menu = buildMenu()
    }
    
    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false
        
//        let settingsView = SettingsView()
//        let controller = NSHostingController(rootView: settingsView)
//        controller.view.frame.size = CGSize(width: 200, height: 100)
//        
//        let menuItem = NSMenuItem()
//        menuItem.view = controller.view
//        menuItem.isHidden = false
//        menu.addItem(menuItem)
//        menu.addItem(.separator())
//        self.switcherMenuItem = menuItem
        
        let settingsMenuItem = NSMenuItem(
            title: "Settings",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsMenuItem.target = self
        menu.addItem(settingsMenuItem)

        menu.addItem(.separator())
        
        let quitMenuItem = NSMenuItem(
            title: "Quit",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
        return menu
    }
    
    @objc private func onStatusBarClick() {
        debugPrint("Status bar item clicked")
    }
    
    @objc private func openSettings() {
        AppDelegate.instance.openSettingsWindow()
    }
    
    @objc private func quit() {
        NSApp.terminate(self)
    }
}
