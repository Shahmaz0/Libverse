import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case hindi = "hi"
    case kannada = "kn"
    
    var id: String { self.rawValue }
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .hindi: return "हिंदी"
        case .kannada: return "ಕನ್ನಡ"
        }
    }
}

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: AppLanguage {
        didSet {
            UserDefaults.standard.set(currentLanguage.rawValue, forKey: "appLanguage")
            NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)
        }
    }
    
    private init() {
        let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage") ?? AppLanguage.english.rawValue
        if let language = AppLanguage(rawValue: savedLanguage) {
            self.currentLanguage = language
        } else {
            self.currentLanguage = .english
        }
    }
    
    // Function to get localized string
    func localizedString(_ key: String) -> String {
        let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj")
        let bundle = path != nil ? Bundle(path: path!) : Bundle.main
        return NSLocalizedString(key, tableName: nil, bundle: bundle ?? Bundle.main, value: key, comment: "")
    }
    
    // Function to translate author names
    func translateAuthor(_ author: String) -> String {
        // If we're already in English mode, just return the original
        if currentLanguage == .english {
            return author
        }
        
        // Determine target language
        let targetLanguage = currentLanguage.rawValue
        
        // For synchronous access, we'll have to use a wrapper that blocks
        // In a production app, you might want to implement this differently
        var result = "[\(author) - translated]" // Default fallback value
        
        // Create a semaphore to wait for async translation
        let semaphore = DispatchSemaphore(value: 0)
        
        // Use the translation manager
        TranslationManager.shared.translateText(author, from: "en", to: targetLanguage) { translationResult in
            switch translationResult {
            case .success(let translatedString):
                result = translatedString
            case .failure:
                // Keep the fallback value
                break
            }
            semaphore.signal()
        }
        
        // Wait for the translation with timeout (1 second max)
        _ = semaphore.wait(timeout: .now() + 1.0)
        
        return result
    }
} 