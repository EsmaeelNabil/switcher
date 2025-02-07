//
//  ContentView.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 07.02.25.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var keywords = ""
    
    var body: some View {
        VStack {
            Text("App is Running.\n Press Alt twice")
        }
        .padding()
    }
}

#Preview {
    SettingsView()
}
