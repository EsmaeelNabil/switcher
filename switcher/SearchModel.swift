//
//  SearchModel.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 07.02.25.
//


import Foundation
import SwiftUI
import Cocoa
import CoreGraphics

class SearchModel: ObservableObject {
    @Published var text: String = ""
    @Published var suggestions: [(name: String, icon: NSImage?)] = []
    @Published var selectedIndex: Int? = nil
}
