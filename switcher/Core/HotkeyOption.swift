//
//  HotkeyOption.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 11.02.25.
//

import CoreGraphics

/// A Hashable wrapper for CGEventFlags to be used in UI components.
enum HotkeyOption: Int, CaseIterable, Hashable {
    case alt = 1
    case command = 2
    case shift = 3
    case control = 4

    /// Converts `HotkeyOption` to a CGEventFlags modifier.
    var cgEventFlag: CGEventFlags {
        switch self {
        case .alt: return .maskAlternate
        case .command: return .maskCommand
        case .shift: return .maskShift
        case .control: return .maskControl
        }
    }

    /// Converts CGEventFlags to HotkeyOption.
    static func from(cgEventFlag: CGEventFlags) -> HotkeyOption {
        switch cgEventFlag {
        case .maskAlternate: return .alt
        case .maskCommand: return .command
        case .maskShift: return .shift
        case .maskControl: return .control
        default: return .alt // Default to Alt
        }
    }

    /// UI-friendly name.
    var displayName: String {
        switch self {
        case .alt: return "⌥ Alt"
        case .command: return "⌘ Command"
        case .shift: return "⇧ Shift"
        case .control: return "⌃ Control"
        }
    }
}
