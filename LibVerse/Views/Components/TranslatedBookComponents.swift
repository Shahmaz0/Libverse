import SwiftUI
import NaturalLanguage

// Component to display translated book titles
struct TranslatedBookTitle: View {
    let originalText: String
    @State private var translatedText: String
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    init(_ originalText: String) {
        self.originalText = originalText
        self._translatedText = State(initialValue: originalText)
    }
    
    var body: some View {
        Text(translatedText)
            .onAppear {
                translateIfNeeded()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
                translateIfNeeded()
            }
    }
    
    private func translateIfNeeded() {
        if localizationManager.currentLanguage == .english {
            translatedText = originalText
        } else {
            // Use the TranslationManager to translate the title
            let targetLanguage = localizationManager.currentLanguage.rawValue
            TranslationManager.shared.translateText(originalText, from: "en", to: targetLanguage) { result in
                switch result {
                case .success(let translatedString):
                    DispatchQueue.main.async {
                        translatedText = translatedString
                    }
                case .failure:
                    // Fallback to the original method if translation fails
                    DispatchQueue.main.async {
                        translatedText = "[\(originalText) - translated]"
                    }
                }
            }
        }
    }
}

// Component to display translated book author
struct TranslatedBookAuthor: View {
    let originalText: String
    @State private var translatedText: String
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    init(_ originalText: String) {
        self.originalText = originalText
        self._translatedText = State(initialValue: originalText)
    }
    
    var body: some View {
        Text(translatedText)
            .onAppear {
                translateIfNeeded()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
                translateIfNeeded()
            }
    }
    
    private func translateIfNeeded() {
        if localizationManager.currentLanguage == .english {
            translatedText = originalText
        } else {
            // Use the TranslationManager to translate the author name
            let targetLanguage = localizationManager.currentLanguage.rawValue
            TranslationManager.shared.translateText(originalText, from: "en", to: targetLanguage) { result in
                switch result {
                case .success(let translatedString):
                    DispatchQueue.main.async {
                        translatedText = translatedString
                    }
                case .failure:
                    // Fallback to the original method if translation fails
                    DispatchQueue.main.async {
                        translatedText = "[\(originalText) - translated]"
                    }
                }
            }
        }
    }
}

// Component to display translated book description
struct TranslatedBookDescription: View {
    let originalText: String
    @State private var translatedText: String
    @ObservedObject private var localizationManager = LocalizationManager.shared
    
    init(_ originalText: String) {
        self.originalText = originalText
        self._translatedText = State(initialValue: originalText)
    }
    
    var body: some View {
        Text(translatedText)
            .onAppear {
                translateIfNeeded()
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
                translateIfNeeded()
            }
    }
    
    private func translateIfNeeded() {
        if localizationManager.currentLanguage == .english {
            translatedText = originalText
        } else {
            // Use the TranslationManager to translate the description
            let targetLanguage = localizationManager.currentLanguage.rawValue
            TranslationManager.shared.translateText(originalText, from: "en", to: targetLanguage) { result in
                switch result {
                case .success(let translatedString):
                    DispatchQueue.main.async {
                        translatedText = translatedString
                    }
                case .failure:
                    // Fallback to the original method if translation fails
                    DispatchQueue.main.async {
                        translatedText = "[\(originalText) - translated]"
                    }
                }
            }
        }
    }
} 