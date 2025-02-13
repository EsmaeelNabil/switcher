//
//  AppConfiguration.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 11.02.25.
//

import Foundation
import Cocoa
import CoreGraphics

/// A configuration manager for user settings.
struct AppConfiguration {
    static let keyMapping: [Int64: String] = [
        0: "a", 1: "s", 2: "d", 3: "f", 4: "h",
        5: "g", 6: "z", 7: "x", 8: "c", 9: "v",
        11: "b", 12: "q", 13: "w", 14: "e", 15: "r",
        16: "y", 17: "t", 31: "o", 32: "u", 34: "i",
        35: "p", 37: "l", 38: "j", 40: "k", 45: "n",
        46: "m"
    ]
    
    /// Default value for hotkey detection threshold.
    private static let defaultDoublePressThreshold: CFTimeInterval = 0.3

    /// Retrieves or sets the user's preferred double press threshold.
    static var hotkeyDoublePressThreshold: CFTimeInterval {
        get {
            UserDefaults.standard.double(forKey: "hotkeyDoublePressThreshold") == 0 ?
            defaultDoublePressThreshold : UserDefaults.standard.double(forKey: "hotkeyDoublePressThreshold")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "hotkeyDoublePressThreshold")
        }
    }
    
    /// Default hotkey modifier (Alt/Option key).
    private static let defaultHotkeyModifier: HotkeyOption = .alt

    
    /// Retrieves or sets the user's preferred hotkey modifier (e.g., Alt, Command, Shift).
    static var hotkeyModifier: HotkeyOption {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: "hotkeyModifier")
            return HotkeyOption(rawValue: rawValue) ?? defaultHotkeyModifier
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "hotkeyModifier")
        }
    }
}
