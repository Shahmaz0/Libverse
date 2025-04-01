import Foundation
import SwiftUI

class UserPreferences {
    static let shared = UserPreferences()
    
    // Keys for UserDefaults
    private let genrePreferencesKey = "userGenrePreferences"
    private let completedGenreOnboardingKey = "hasCompletedGenreOnboarding"
    
    private init() {}
    
    // MARK: - Genre Preferences
    
    func saveGenrePreferences(_ genres: [String]) {
        UserDefaults.standard.set(genres, forKey: genrePreferencesKey)
        UserDefaults.standard.set(true, forKey: completedGenreOnboardingKey)
    }
    
    func getGenrePreferences() -> [String] {
        return UserDefaults.standard.stringArray(forKey: genrePreferencesKey) ?? []
    }
    
    func hasCompletedGenreOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: completedGenreOnboardingKey)
    }
    
    func resetGenreOnboarding() {
        UserDefaults.standard.set(false, forKey: completedGenreOnboardingKey)
    }
    
    // MARK: - Clear User Preferences
    
    func clearAllPreferences() {
        // Clear genre preferences
        UserDefaults.standard.removeObject(forKey: genrePreferencesKey)
        UserDefaults.standard.removeObject(forKey: completedGenreOnboardingKey)
        
        // Clear any other user preferences
        print("All user preferences cleared")
    }
} 