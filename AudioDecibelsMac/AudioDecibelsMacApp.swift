//
//  AudioDecibelsMacApp.swift
//  AudioDecibelsMac
//
//  Created by Juan Camilo Marin Ochoa on 21/07/24.
//

import SwiftUI

@main
struct AudioDecibelsMacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .commands {
            CommandGroup(replacing: .appSettings) {
                EmptyView()
            }
        }
    }
}
