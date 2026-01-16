//
//  SambbleApp.swift
//  Sambble
//
//  Created by will on 9/25/25.
//

import SwiftUI
import AVFoundation

@main
struct SambbleApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(SettingsStore.shared)
                .onAppear() {
                    MediaCommandManager.shared.start()
                    SilentAudioPlayer.shared.start()
                }
        }
    }
}


