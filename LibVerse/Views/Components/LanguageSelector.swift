import SwiftUI

struct LanguageSelector: View {
    @State private var showingLanguagePicker = false
    
    var body: some View {
        HStack {
            LocalizedText("language")
                .font(.headline)
            
            Spacer()
            
            Button(action: {
                showingLanguagePicker = true
            }) {
                HStack {
                    Text(LocalizationManager.shared.currentLanguage.displayName)
                        .foregroundColor(.primary)
                    
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
        }
        .padding()
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .cornerRadius(0)
        .overlay(RoundedRectangle(cornerRadius: 0)
            .stroke(Color.black, lineWidth: 1.25))
        .padding(.horizontal)
        .actionSheet(isPresented: $showingLanguagePicker) {
            ActionSheet(
                title: Text(LocalizationManager.shared.localizedString("language")),
                buttons: languageButtons()
            )
        }
    }
    
    private func languageButtons() -> [ActionSheet.Button] {
        var buttons: [ActionSheet.Button] = []
        
        for language in AppLanguage.allCases {
            buttons.append(.default(Text(language.displayName)) {
                LocalizationManager.shared.currentLanguage = language
            })
        }
        
        buttons.append(.cancel())
        return buttons
    }
} 