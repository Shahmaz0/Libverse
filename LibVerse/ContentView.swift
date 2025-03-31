import SwiftUI

struct ContentView: View {
    
    var isAuthenticated: Bool = false
    
    var body: some View {
        if isAuthenticated{
            TabBarView()
        }else{
            LogInView()
        }
    }
}
    
    
#Preview {
    ContentView()
}
