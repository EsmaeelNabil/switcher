//
//  Events.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 07.02.25.
//


import Foundation
import SwiftUI
import Cocoa
import CoreGraphics

func eventTapCallback(proxy: CGEventTapProxy,
                              type: CGEventType,
                              event: CGEvent,
                              refcon: UnsafeMutableRawPointer?) -> Unmanaged<CGEvent>? {
    guard let refcon = refcon else { return Unmanaged.passRetained(event) }
    let delegate = Unmanaged<AppDelegate>.fromOpaque(refcon).takeUnretainedValue()
    switch type {
    case .flagsChanged:
        delegate.handleFlagsChanged(event)
    case .keyDown:
        return delegate.handleKeyDown(event)
    default:
        break
    }
    return Unmanaged.passRetained(event)
}
