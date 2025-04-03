import SwiftUI
import Supabase

struct ContentView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated: Bool = false
    @State private var showGenrePreferences: Bool = false
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var isCheckingAuth: Bool = true
    
    var body: some View {
        Group {
            if isCheckingAuth {
                // Show a splash screen or loading view while checking auth
                Color(red: 255/255, green: 239/255, blue: 210/255)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        ProgressView()
                    )
            } else if isAuthenticated {
                TabBarView()
                    .environmentObject(supabaseManager)
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UserDidLogout"))) { _ in
                        // Update authentication state when user logs out
                        isAuthenticated = false
                    }
            } else {
                LogInView()
                    .environmentObject(supabaseManager)
                    .onReceive(NotificationCenter.default.publisher(for: Notification.Name("userLoggedIn"))) { _ in
                        isAuthenticated = true
                    }
            }
        }
        .onAppear {
            validateAuthentication()
        }
    }
    
    private func validateAuthentication() {
        // Always verify session is valid
        Task {
            do {
                // Check if we have a valid stored session
                let session = try? await SupabaseManager.shared.client.auth.session
                let hasCurrentUser = session?.user != nil
                
                // Additional check: verify if we have the user's email saved
                // This should be cleared if app is reinstalled
                let hasUserEmail = UserDefaults.standard.string(forKey: "userEmail") != nil 
                
                if isAuthenticated && hasCurrentUser && hasUserEmail {
                    // Valid session exists, restore user and member data
                    SupabaseManager.shared.currentUser = session?.user
                    SupabaseManager.shared.currentSession = session
                    await SupabaseManager.shared.fetchCurrentMember()
                    DispatchQueue.main.async {
                        isCheckingAuth = false
                    }
                } else {
                    // No valid session or user email missing, reset authentication
                    SupabaseManager.shared.clearCredentials()
                    DispatchQueue.main.async {
                        isAuthenticated = false
                        isCheckingAuth = false
                    }
                }
            } catch {
                print("Failed to validate authentication: \(error)")
                SupabaseManager.shared.clearCredentials()
                DispatchQueue.main.async {
                    isAuthenticated = false
                    isCheckingAuth = false
                }
            }
        }
    }
}
    
#Preview {
    ContentView()
}
