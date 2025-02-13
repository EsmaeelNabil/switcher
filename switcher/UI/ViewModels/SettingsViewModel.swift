//
//  SettingsViewModel.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 11.02.25.
//

import Foundation
import SwiftUI

/// A ViewModel for managing app settings in the UI.
class SettingsViewModel: ObservableObject {
    /// The hotkey detection threshold, synced with UserDefaults.
    @Published var hotkeyThreshold: Double {
        didSet {
            AppConfiguration.hotkeyDoublePressThreshold = hotkeyThreshold
        }
    }
    
    /// Selected hotkey modifier.
    @Published var selectedHotkeyModifier: HotkeyOption {
         didSet {
             AppConfiguration.hotkeyModifier = selectedHotkeyModifier
         }
     }
    

    init() {
        self.hotkeyThreshold = AppConfiguration.hotkeyDoublePressThreshold
        self.selectedHotkeyModifier = AppConfiguration.hotkeyModifier
    }
}
