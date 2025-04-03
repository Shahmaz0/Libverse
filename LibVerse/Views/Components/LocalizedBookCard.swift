import SwiftUI

struct LocalizedBookCard: View {
    let bookImage: String
    let title: String
    let author: String
    let description: String
    let showPlusButton: Bool
    
    @State private var translatedTitle: String
    @State private var translatedAuthor: String
    @State private var translatedDescription: String
    
    init(bookImage: String, title: String, author: String, description: String, showPlusButton: Bool) {
        self.bookImage = bookImage
        self.title = title
        self.author = author
        self.description = description
        self.showPlusButton = showPlusButton
        
        // Initial values
        self._translatedTitle = State(initialValue: title)
        self._translatedAuthor = State(initialValue: author)
        self._translatedDescription = State(initialValue: description)
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Book cover
            AsyncImage(url: URL(string: bookImage)) { phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else if phase.error != nil {
                    Image(systemName: "book.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                } else {
                    ProgressView()
                }
            }
            .frame(width: 80, height: 120)
            .cornerRadius(0)
            .overlay(RoundedRectangle(cornerRadius: 0)
                .stroke(Color.black, lineWidth: 1.25))
            
            // Book details
            VStack(alignment: .leading, spacing: 5) {
                Text(translatedTitle)
                    .font(.headline)
                    .lineLimit(2)
                
                Text(translatedAuthor)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Text(translatedDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(3)
            }
            
            Spacer()
            
            // Plus button if needed
            if showPlusButton {
                Button(action: {}) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .foregroundColor(Color(red: 255/255, green: 111/255, blue: 45/255))
                }
                .padding([.top, .trailing], 5)
            }
        }
        .padding()
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .cornerRadius(0)
        .overlay(RoundedRectangle(cornerRadius: 0)
            .stroke(Color.black, lineWidth: 1.25))
        .onAppear {
            translateContent()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LanguageChanged"))) { _ in
            translateContent()
        }
    }
    
    private func translateContent() {
        if LocalizationManager.shared.currentLanguage == .english {
            translatedTitle = title
            translatedAuthor = author
            translatedDescription = description
        } else {
            // Simple mock translation for Hindi
            translatedTitle = "[\(title) - हिंदी में]"
            translatedAuthor = "[\(author) - हिंदी में]"
            translatedDescription = "[\(description) - हिंदी में]"
        }
    }
} 