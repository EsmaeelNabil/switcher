//
//  Text+Extensions.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 07.02.25.
//

import SwiftUI
import Cocoa

/// Returns a SwiftUI Text view with the matching query highlighted.
/// - Parameters:
///   - suggestion: The suggestion text.
///   - query: The search query.
/// - Returns: A Text view with the matching portion highlighted.
func highlightedText(for suggestion: String, query: String) -> Text {
    guard !query.isEmpty,
          let range = suggestion.range(of: query, options: .caseInsensitive) else {
        return Text(suggestion)
    }
    let before = String(suggestion[..<range.lowerBound])
    let match = String(suggestion[range])
    let after = String(suggestion[range.upperBound...])
    return Text(before) + Text(match).foregroundColor(.accentColor).bold() + Text(after)
}
