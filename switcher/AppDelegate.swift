//
//  AppDelegate.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 07.02.25.
//

import Foundation
import SwiftUI
import Cocoa
import CoreGraphics

class AppDelegate: NSObject, NSApplicationDelegate {
    static private(set) var instance: AppDelegate!
    
    var statusBarController: StatusBarController!
    var eventTap: CFMachPort?
    var runLoopSource: CFRunLoopSource?
    
    // Double Alt detection
    var lastAltPressTime: CFAbsoluteTime = 0
    var lastCharPressTime: CFAbsoluteTime = 0
    let doublePressThreshold: CFTimeInterval = 0.3
    let doubleCharPressThreadhold: CFTimeInterval = 0.5
    
    // Search mode state
    var searchMode = false
    var searchString = ""
    var searchWindowController: SearchWindowController?


    
    // SwiftUI search popover
    var searchModel = SearchModel()
    var searchPopover: NSPopover?
    var searchPop: NSPanel?
    
    // Key mapping for letters.
    let keyMapping: [Int64: String] = [
        0: "a", 1: "s", 2: "d", 3: "f", 4: "h",
        5: "g", 6: "z", 7: "x", 8: "c", 9: "v",
        11: "b", 12: "q", 13: "w", 14: "e", 15: "r",
        16: "y", 17: "t", 31: "o", 32: "u", 34: "i",
        35: "p", 37: "l", 38: "j", 40: "k", 45: "n",
        46: "m"
    ]
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.instance = self
        statusBarController = StatusBarController()
        setupEventTap()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let eventTap = eventTap, let runLoopSource = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
            CFMachPortInvalidate(eventTap)
        }
    }
    
    func setupSearchWindow() {
           if searchWindowController == nil {
               searchWindowController = SearchWindowController(model: searchModel)
           }
       }
    

    func updateSearchWindow() {
        searchModel.text = searchString
        searchModel.suggestions = getSuggestions(for: searchString)
        searchModel.selectedIndex = searchModel.suggestions.isEmpty ? nil : 0

        if searchWindowController == nil {
            setupSearchWindow()
        }
        
        searchWindowController?.showWindow(nil)
    }

    func closeSearchWindow() {
        searchWindowController?.closeWindow()
        searchWindowController = nil
    }

    func getSuggestions(for query: String) -> [(name: String, icon: NSImage?)] {
        let visibleApps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular }
        
        let results: [(name: String, icon: NSImage?)]
        if query.isEmpty {
            results = visibleApps.compactMap { app in
                guard let name = app.localizedName else { return nil }
                return (name, app.icon)
            }
        } else {
            let lowerQuery = query.lowercased()
            results = visibleApps.compactMap { app in
                guard let name = app.localizedName, name.lowercased().contains(lowerQuery) else { return nil }
                return (name, app.icon)
            }
        }
        return results.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    
    // MARK: - Global Event Tap Setup
    
    func setupEventTap() {
        let mask = (1 << CGEventType.flagsChanged.rawValue) | (1 << CGEventType.keyDown.rawValue)
        eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                     place: .headInsertEventTap,
                                     options: .defaultTap,
                                     eventsOfInterest: CGEventMask(mask),
                                     callback: eventTapCallback,
                                     userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()))
        guard let eventTap = eventTap else {
            print("Unable to create event tap. Ensure accessibility permissions are granted.")
            exit(1)
        }
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
    }
    
    func handleFlagsChanged(_ event: CGEvent) {
        if event.flags.contains(.maskAlternate) {
            let now = CFAbsoluteTimeGetCurrent()
            if now - lastAltPressTime < doublePressThreshold {
                searchMode = true
                searchString = ""
                print("Double Alt detected: opening search window")
                updateSearchWindow()
            }
            lastAltPressTime = now
        }
    }
    
    func handleKeyDown(_ event: CGEvent) -> Unmanaged<CGEvent>? {
        guard searchMode else { return Unmanaged.passRetained(event) }
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)

        if keyCode == 53 { // Escape
            searchMode = false
            searchString = ""
            closeSearchWindow()
            return nil
        }

        if keyCode == 125 { // Down arrow
            if let current = searchModel.selectedIndex, !searchModel.suggestions.isEmpty {
                searchModel.selectedIndex = (current + 1) % searchModel.suggestions.count
            } else if !searchModel.suggestions.isEmpty {
                searchModel.selectedIndex = 0
            }
            return nil
        }

        if keyCode == 126 { // Up arrow
            if let current = searchModel.selectedIndex, !searchModel.suggestions.isEmpty {
                searchModel.selectedIndex = (current - 1 + searchModel.suggestions.count) % searchModel.suggestions.count
            } else if !searchModel.suggestions.isEmpty {
                searchModel.selectedIndex = searchModel.suggestions.count - 1
            }
            return nil
        }
        
        if keyCode == 36 { // Return key
            onPressEnter()
            return nil
        }
        
        if keyCode == 51 { // Delete key
            if !searchString.isEmpty {
                searchString.removeLast()
                updateSearchWindow()
            }
            return nil
        }

        if let char = keyMapping[keyCode] {
            searchString.append(char)
            updateSearchWindow()
            // open the app if it's the only option with 2 chars, otherwise ignore.
            if(searchString.count > 1 && searchModel.suggestions.count == 1 ){
                onPressEnter()
            }
        }
        
        return nil
    }
    
    func onPressEnter(){
        if let index = searchModel.selectedIndex, index < searchModel.suggestions.count {
            searchString = searchModel.suggestions[index].name
        }
        performAppSearch(query: searchString)
        searchMode = false
        searchString = ""
        closeSearchWindow()
    }

    
    func performAppSearch(query: String) {
        let visibleApps = NSWorkspace.shared.runningApplications.filter {
            $0.activationPolicy == .regular
        }
        let lowerQuery = query.lowercased()
        let matches = visibleApps.filter { app in
            if let name = app.localizedName?.lowercased() {
                return name.contains(lowerQuery)
            }
            return false
        }
        if let match = matches.first {
            if !match.activate(options: [.activateAllWindows]) {
                print("Activation request was not honored.")
            }
            searchMode = false
            searchString = ""
            print("Activating app: \(match.localizedName ?? "Unknown")")
        } else {
            print("No matching app found for query \(query)")
        }
    }
}


    

