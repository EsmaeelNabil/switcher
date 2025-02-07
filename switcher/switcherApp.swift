//
//  switcherApp.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 07.02.25.
//

import SwiftUI

@main
struct switcherApp: App {
    
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}


