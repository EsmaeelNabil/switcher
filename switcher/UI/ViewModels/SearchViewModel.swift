//
//  SearchViewModel.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 11.02.25.
//

import Foundation
import SwiftUI
import Cocoa

/// ViewModel for the search functionality, adhering to MVVM principles.
/// It encapsulates business logic for fetching app suggestions and handling key events.
class SearchViewModel: ObservableObject {
    /// The current search text.
    @Published var text: String = ""
    
    /// List of suggestions based on the search text.
    @Published var suggestions: [(name: String, icon: NSImage?)] = []
    
    /// The index of the currently selected suggestion.
    @Published var selectedIndex: Int? = nil
    
    /// Updates suggestions based on the current text.
    func updateSuggestions() {
        let visibleApps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular }
        if text.isEmpty {
            suggestions = visibleApps.compactMap { app in
                guard let name = app.localizedName else { return nil }
                return (name, app.icon)
            }
        } else {
            let lowerQuery = text.lowercased()
            suggestions = visibleApps.compactMap { app in
                guard let name = app.localizedName, name.lowercased().contains(lowerQuery) else { return nil }
                return (name, app.icon)
            }
        }
        suggestions.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        selectedIndex = suggestions.isEmpty ? nil : 0
    }
    
    /// Activates the selected app based on the current search text.
    func performSearch() {
        let visibleApps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .regular }
        let lowerQuery = text.lowercased()
        let matches = visibleApps.filter { app in
            if let name = app.localizedName?.lowercased() {
                return name.contains(lowerQuery)
            }
            return false
        }
        if let match = matches.first {
            _ = match.activate(options: [.activateAllWindows])
        }
    }
}
