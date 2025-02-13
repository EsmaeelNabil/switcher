//
//  Events.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 07.02.25.
//

import Cocoa
import CoreGraphics

/// Global event tap callback that dispatches events to the EventHandler.
/// - Parameters:
///   - proxy: The event tap proxy.
///   - type: The type of event.
///   - event: The incoming CGEvent.
///   - refcon: A pointer to the AppDelegate instance.
/// - Returns: The (possibly modified) event.
func eventTapCallback(proxy: CGEventTapProxy,
                      type: CGEventType,
                      event: CGEvent,
                      refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard let refcon = refcon else { return Unmanaged.passRetained(event) }
    let appDelegate = Unmanaged<AppDelegate>.fromOpaque(refcon).takeUnretainedValue()
    
    switch type {
    case .flagsChanged:
        appDelegate.eventHandler.handleFlagsChanged(event)
        // When in search mode, swallow the flagsChanged event.
        return appDelegate.searchMode ? nil : Unmanaged.passRetained(event)
        
    case .keyDown:
        appDelegate.eventHandler.handleKeyDown(event)
        // When in search mode, return nil to prevent propagation.
        return appDelegate.searchMode ? nil : Unmanaged.passRetained(event)
        
    default:
        return Unmanaged.passRetained(event)
    }
}

