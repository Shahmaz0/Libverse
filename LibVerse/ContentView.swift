import SwiftUI
import Supabase

struct ContentView: View {
    @State private var isAuthenticated: Bool = false
    @State private var showGenrePreferences: Bool = false
    @StateObject private var supabaseManager = SupabaseManager.shared
    
    var body: some View {
        if isAuthenticated {
            TabBarView()
                .environmentObject(supabaseManager)
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UserDidLogout"))) { _ in
                    // Update authentication state when user logs out
                    isAuthenticated = false
                }
        } else {
            LogInView()
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
                                    isAuthenticated = true
                                }
                            }
                        } catch {
                            print("No active session found: \(error)")
                        }
                    }
                }
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("userLoggedIn"))) { _ in
                    isAuthenticated = true
                }
        }
    }
}
    
#Preview {
    ContentView()
}
