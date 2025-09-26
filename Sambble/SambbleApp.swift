//
//  SambbleApp.swift
//  Sambble
//
//  Created by will on 9/25/25.
//

import SwiftUI

@main
struct SambbleApp: App {
    let quiz = loadQuiz(length: 7)
    var body: some Scene {
        WindowGroup {
            RootView(quiz: quiz)
        }
    }
}
