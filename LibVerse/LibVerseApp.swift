//
//  LibVerseApp.swift
//  LibVerse
//
//  Created by Shahma Ansari on 18/03/25.
//

import SwiftUI

@main
struct LibVerseApp: App {
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @State private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .id(localizationManager.currentLanguage.rawValue) // Force view refresh when language changes
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
                    // This will force the ContentView to refresh when language changes
                }
        }
    }
}

class AppState: ObservableObject {
    @Published var showMainApp = false
    @Published var showUserInitialView = true
}
