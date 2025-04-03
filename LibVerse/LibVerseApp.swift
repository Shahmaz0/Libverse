//
//  LibVerseApp.swift
//  LibVerse
//
//  Created by Shahma Ansari on 18/03/25.
//

import SwiftUI

@main
struct LibVerseApp: App {
    // Initialize SupabaseManager at the app level
    @StateObject private var supabaseManager = SupabaseManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(supabaseManager)
        }
    }
}
