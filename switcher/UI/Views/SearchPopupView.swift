//
//  SearchPopupView.swift
//  switcher
//
//  Created by Esmaeel Moustafa on 11.02.25.
//

import SwiftUI
import Cocoa

/// A SwiftUI view displaying the search popup.
struct SearchPopupView: View {
    /// The view model driving the search logic.
    @ObservedObject var viewModel: SearchViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if !viewModel.text.isEmpty {
                Text(viewModel.text)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(Color.black.opacity(0.1))
                    .cornerRadius(100)
                    .shadow(color: Color.black, radius: -10, x: 0, y: 10)
            }
            
            ForEach(viewModel.suggestions.indices, id: \.self) { index in
                let suggestion = viewModel.suggestions[index]
                HStack(spacing: 8) {
                    if let icon = suggestion.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 16, height: 16)
                    }
                    highlightedText(for: suggestion.name, query: viewModel.text)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(index == viewModel.selectedIndex ? Color.blue.opacity(0.3) : Color.clear)
                .cornerRadius(6)
                .contentShape(Rectangle())
                .onTapGesture { viewModel.selectedIndex = index }
            }
        }
        .padding()
        .frame(width: 350)
        .background(BlurView())
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: Color.black.opacity(0.2), radius: 10)
    }
}

/// A NSVisualEffectView wrapper to provide a blur background.
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

#Preview {
    SearchPopupView(viewModel: SearchViewModel())
}
