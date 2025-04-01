import SwiftUI

struct ContentView: View {
    @AppStorage("isAuthenticated") var isAuthenticated: Bool = false
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    
    var body: some View {
        if !isAuthenticated {
            LogInView()
        } else if !hasCompletedOnboarding {
            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
        } else {
            TabBarView()
        }
    }
}
    
#Preview {
    ContentView()
} 