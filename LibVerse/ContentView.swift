import SwiftUI
import Supabase

struct ContentView: View {
    @ObservedObject var appState: AppState
    @ObservedObject private var localizationManager = LocalizationManager.shared
    @StateObject private var supabaseManager = SupabaseManager.shared
    
    var body: some View {
        if appState.showMainApp {
            TabBarView()
                .environmentObject(supabaseManager)
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UserDidLogout"))) { _ in
                    // Update authentication state when user logs out
                    appState.showMainApp = false
                    appState.showUserInitialView = true
                }
                .id(localizationManager.currentLanguage.rawValue) // Force view refresh when language changes
        } else {
            LogInView(showMainApp: $appState.showMainApp, showUserInitialView: $appState.showUserInitialView)
                .environmentObject(supabaseManager)
                .onAppear {
                    // Check if user is already logged in
                    Task {
                        do {
                            // Use try? to make the session optional
                            let session = try? await SupabaseManager.shared.client.auth.session
                            
                            // Only proceed if we have a valid session
                            if let session = session {
                                SupabaseManager.shared.currentUser = session.user
                                SupabaseManager.shared.currentSession = session
                                await SupabaseManager.shared.fetchCurrentMember()
                                DispatchQueue.main.async {
                                    appState.showMainApp = true
                                    appState.showUserInitialView = false
                                }
                            }
                        } catch {
                            print("No active session found: \(error)")
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("userLoggedIn"))) { _ in
                    appState.showMainApp = true
                    appState.showUserInitialView = false
                }
                .id(localizationManager.currentLanguage.rawValue) // Force view refresh when language changes
        }
    }
}
    
#Preview {
    ContentView(appState: AppState())
}
