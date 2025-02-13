//
//  AppDelegate.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 07.02.25.
//

import Cocoa
import SwiftUI
import CoreGraphics

/// The main application delegate managing lifecycle, events, and search.
class AppDelegate: NSObject, NSApplicationDelegate, EventHandlingDelegate {
    /// Shared instance for global access.
    static private(set) var instance: AppDelegate!
    
    var statusBarController: StatusBarController!
    var eventTap: CFMachPort?
    var runLoopSource: CFRunLoopSource?
    
    /// Indicates whether the app is in search mode.
    var searchMode = false
    
    /// Current accumulated search string.
    var searchString = ""
    
    /// Controller for the search window.
    var searchWindowController: SearchWindowController?
    var settingsWindowController: SettingsWindowController?

    
    /// The view model backing the search popup.
    var searchViewModel = SearchViewModel()
    var settingsViewModel = SettingsViewModel()

    /// Core event handler.
    let eventHandler = EventHandler()
    
    override init() {
        super.init()
        AppDelegate.instance = self
        // Observe hotkey changes
               NotificationCenter.default.addObserver(self, selector: #selector(reloadEventTap), name: UserDefaults.didChangeNotification, object: nil)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()
        eventHandler.delegate = self
        setupEventTap()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        removeEventTap()
    }
    
    /// Reloads event tap when settings change
    @objc func reloadEventTap() {
        removeEventTap()
        setupEventTap()
    }

    
    /// Removes the current event tap.
    func removeEventTap() {
        if let eventTap = eventTap, let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CFMachPortInvalidate(eventTap)
        }
    }
    
    // MARK: - Search Window Management
    
    /// Initializes and displays the search window if not already active.
    func setupSearchWindow() {
        if searchWindowController == nil {
            searchWindowController = SearchWindowController(viewModel: searchViewModel)
        }
    }
    
    /// Updates the search view model and shows the search window.
    func updateSearchWindow() {
        searchViewModel.text = searchString
        searchViewModel.updateSuggestions()
        if searchWindowController == nil {
            setupSearchWindow()
        }
    }
    
    /// Closes the search window.
    func closeSearchWindow() {
        searchWindowController?.closeWindow()
        searchWindowController = nil
    }
    
    // MARK: - EventHandlingDelegate
    
    func didTriggerHotkey() {
        searchMode = true
        searchString = ""
        print("Hotkey triggered: opening search window")
        updateSearchWindow()
    }
    
    func didReceiveKeyDown(keyCode: Int64) {
        guard searchMode else { return }
        switch keyCode {
        case 53: // Escape key
            searchMode = false
            searchString = ""
            closeSearchWindow()
        case 125: // Down arrow
            if let current = searchViewModel.selectedIndex, !searchViewModel.suggestions.isEmpty {
                searchViewModel.selectedIndex = (current + 1) % searchViewModel.suggestions.count
            } else if !searchViewModel.suggestions.isEmpty {
                searchViewModel.selectedIndex = 0
            }
        case 126: // Up arrow
            if let current = searchViewModel.selectedIndex, !searchViewModel.suggestions.isEmpty {
                searchViewModel.selectedIndex = (current - 1 + searchViewModel.suggestions.count) % searchViewModel.suggestions.count
            } else if !searchViewModel.suggestions.isEmpty {
                searchViewModel.selectedIndex = searchViewModel.suggestions.count - 1
            }
        case 36: // Return key
            onPressEnter()
        case 51: // Delete key
            if !searchString.isEmpty {
                searchString.removeLast()
                updateSearchWindow()
            }
        default:
            if let char = AppConfiguration.keyMapping[keyCode] {
                searchString.append(char)
                updateSearchWindow()
                if searchString.count > 1 && searchViewModel.suggestions.count == 1 {
                    onPressEnter()
                }
            }
        }
    }
    
    /// Finalizes the search and activates the selected application.
    func onPressEnter() {
        if let index = searchViewModel.selectedIndex, index < searchViewModel.suggestions.count {
            searchString = searchViewModel.suggestions[index].name
        }
        searchViewModel.text = searchString
        searchViewModel.performSearch()
        searchMode = false
        searchString = ""
        closeSearchWindow()
    }
    
    // Open settings in a separate window
      func openSettingsWindow() {
          if settingsWindowController == nil {
              settingsWindowController = SettingsWindowController(viewModel: settingsViewModel)
          }
      }
    
    // MARK: - Global Event Tap Setup
    
    /// Sets up the global event tap with the latest hotkey.
    func setupEventTap() {
        let mask = (1 << CGEventType.flagsChanged.rawValue) | (1 << CGEventType.keyDown.rawValue)
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: eventTapCallback,
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )
        guard let eventTap = eventTap else {
            print("Unable to create event tap. Ensure accessibility permissions are granted.")
            exit(1)
        }
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
}
