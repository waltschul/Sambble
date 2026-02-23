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
                    if SettingsStore.shared.carMode {
                        SilentAudioPlayer.shared.start()
                        MediaCommandManager.shared.start()
                    }
                }
                .onChange(of: SettingsStore.shared.carMode) { _, newValue in
                    if newValue {
                        SilentAudioPlayer.shared.start()
                        MediaCommandManager.shared.start()
                    } else {
                        MediaCommandManager.shared.stop()
                    }
                }
        }
    }
}


