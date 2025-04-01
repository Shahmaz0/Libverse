import SwiftUI
import Supabase

struct ContentView: View {
    @State private var isAuthenticated: Bool = false
    @State private var showGenrePreferences: Bool = false
    
    var body: some View {
        if isAuthenticated {
            TabBarView()
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("UserDidLogout"))) { _ in
                    // Update authentication state when user logs out
                    isAuthenticated = false
                }
        } else {
            LogInView()
                .onAppear {
                    // Check if user is already logged in
                    Task {
                        do {
                            let session = try await SupabaseManager.shared.client.auth.session
                            if session != nil {
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
