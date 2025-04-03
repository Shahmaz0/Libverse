import SwiftUI

struct LocalizedText: View {
    let key: String
    
    init(_ key: String) {
        self.key = key
    }
    
    var body: some View {
        Text(LocalizationManager.shared.localizedString(key))
    }
}

struct DynamicText: View {
    private let text: String
    @State private var translatedText: String
    
    init(_ text: String) {
        self.text = text
        self._translatedText = State(initialValue: text)
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
        if LocalizationManager.shared.currentLanguage == .english {
            translatedText = text
        } else {
            // Simple mock translation for Hindi
            translatedText = "[\(text) - हिंदी में]"
        }
    }
} 