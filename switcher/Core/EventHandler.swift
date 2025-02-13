//
//  EventHandler.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 11.02.25.
//

import Cocoa
import CoreGraphics

/// A protocol for receiving global key event callbacks.
protocol EventHandlingDelegate: AnyObject {
    func didTriggerHotkey()
    func didReceiveKeyDown(keyCode: Int64)
}

/// Handles global keyboard events and notifies its delegate.
class EventHandler {
    weak var delegate: EventHandlingDelegate?

    private var lastHotkeyPressTime: CFAbsoluteTime = 0
    private let doublePressThreshold: CFTimeInterval = AppConfiguration.hotkeyDoublePressThreshold

    /// Dynamically retrieves the selected hotkey modifier.
    var hotkeyModifier: CGEventFlags {
        return AppConfiguration.hotkeyModifier.cgEventFlag
    }

    func handleFlagsChanged(_ event: CGEvent) {
        guard event.flags.contains(hotkeyModifier) else { return }
        let now = CFAbsoluteTimeGetCurrent()
        if now - lastHotkeyPressTime < doublePressThreshold {
            delegate?.didTriggerHotkey()
        }
        lastHotkeyPressTime = now
    }

    func handleKeyDown(_ event: CGEvent) {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        delegate?.didReceiveKeyDown(keyCode: keyCode)
    }
}
