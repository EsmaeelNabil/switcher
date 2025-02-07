//
//  Text+Extensions.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 07.02.25.
//


import Foundation
import SwiftUI
import Cocoa
import CoreGraphics

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
