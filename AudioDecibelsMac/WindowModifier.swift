//
//  WindowModifier.swift
//  AudioDecibelsMac
//
//  Created by Juan Camilo Marin Ochoa on 21/07/24.
//

import SwiftUI

struct WindowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(WindowAccessor())
    }
}

private struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let nsView = NSView()
        DispatchQueue.main.async {
            if let window = nsView.window {
                window.setContentSize(NSSize(width: 300, height: 760))
                window.minSize = NSSize(width: 300, height: 400)
                window.maxSize = NSSize(width: 300, height: 760)
            }
        }
        return nsView
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}

extension View {
    func windowConstraints() -> some View {
        self.modifier(WindowModifier())
    }
}
