//
//  SearchPopupView.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 07.02.25.
//

import Foundation
import SwiftUI
import Cocoa
import CoreGraphics

struct SearchPopupView: View {
    @ObservedObject var model: SearchModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            
            if !model.text.isEmpty {
                Text(model.text)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(100)
                    .shadow(color: Color.black, radius: -10, x: 0, y: 10)
            }
            
            ForEach(model.suggestions.indices, id: \.self) { index in
                let suggestion = model.suggestions[index]
                HStack(spacing: 8) {
                    if let icon = suggestion.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    highlightedText(for: suggestion.name, query: model.text)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(index == model.selectedIndex ? Color.blue.opacity(0.3) : Color.clear)
                .cornerRadius(6)
                .contentShape(Rectangle())
                .onTapGesture { model.selectedIndex = index }
                
            }
        }
        .padding()
        .frame(width: 350)
        .background(BlurView())
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.2), radius: 10)
    }
}

// Glass Effect Background
struct BlurView: NSViewRepresentable {
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = .hudWindow
        view.blendingMode = .withinWindow
        view.state = .active
        return view
    }
    
    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {}
}
