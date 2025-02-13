//
//  SettingsView.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 11.02.25.
//

import SwiftUI

/// A SwiftUI settings panel for user preferences.
struct SettingsView: View {
    @ObservedObject var viewModel = SettingsViewModel()
    let hotkeyOptions: [(String, CGEventFlags)] = [
        ("⌥ Alt", .maskAlternate),
        ("⌘ Command", .maskCommand),
        ("⇧ Shift", .maskShift),
        ("⌃ Control", .maskControl)
    ]
    
    var body: some View {
        
        
        VStack(spacing: 0) {
            
            
            VStack(alignment: .leading) {
                Text("Hotkey Threshold : \(String(format: "%.2f", viewModel.hotkeyThreshold))s")
                    .font(.subheadline)
                
                // Slider to adjust hotkey sensitivity
                Slider(value: $viewModel.hotkeyThreshold, in: 0.1...5.0, step: 0.05)
                
            }           .padding(16.0)
            
            // Hotkey Modifier Selector
            VStack(alignment: .leading) {
                Text("Choose Hotkey Modifier").font(.subheadline)
                
                Picker("Hotkey Modifier", selection: $viewModel.selectedHotkeyModifier) {
                    ForEach(HotkeyOption.allCases, id: \.self) { option in
                        Text(option.displayName).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }           .padding(16.0)
            
        }
        .padding(16.0)
        .background(BlurView())
        .shadow(color: Color.black.opacity(0.2), radius: 10)
    }
    
}
#Preview {
    SettingsView()
}
