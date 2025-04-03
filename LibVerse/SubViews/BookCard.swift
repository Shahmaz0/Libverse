import SwiftUI
// Remove CommonCrypto import since it's not used directly
// import CommonCrypto

// Remove the implementation-only import
// @_implementationOnly import LibVerse.Utils.ImageCache

// Instead, use a regular import for the entire application
// import LibVerse

// Forward declaration of a wrapper for BookCardCachedImage
struct BookImageView: View {
    let url: String
    
    var body: some View {
        if url.isEmpty {
            Image("mvc")
                .resizable()
                .scaledToFill()
                .frame(width: 45, height: 60)
                .clipped()
                .background(Color.white)
        } else {
            // Use standard AsyncImage since we handle caching in myshelf.swift
            AsyncImage(url: URL(string: url)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 45, height: 60)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 45, height: 60)
                        .clipped()
                case .failure:
                    Image("mvc")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 45, height: 60)
                        .clipped()
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 45, height: 60)
            .clipped()
        }
    }
}

struct BookCard: View {
    let BookImage: String
    let title: String
    let author: String
    let description: String
    var showPlusButton: Bool = false
    var onPlusButtonTapped: (() -> Void)? = nil
    var isAdded: Bool = false
    var menuAction: (() -> Void)? = nil
    var dueDate: Date? = nil
    var fine: Float? = nil
    var isLost: Bool = false
    
    private var daysLeft: String {
        guard let dueDate = dueDate else { return "" }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: dueDate).day ?? 0
        return "\(days) days left"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Rectangle()
                        .stroke(Color.black, lineWidth: 0.5)
                        .frame(width: 50, height: 65)
                    
                    BookImageView(url: BookImage)
                }
                .frame(width: 44, height: 59)
                .padding(.leading, 10)

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.custom("Charter", size: 15))
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("By \(author)")
                        .font(.custom("Charter", size: 12))
                        .foregroundColor(Color(.systemGray))
                        .italic()
                        .lineLimit(1)
                    
                    Spacer().frame(height: 6)
                    
                    if dueDate != nil && !isLost {
                        Text(daysLeft)
                            .font(.custom("Charter", size: 12))
                            .foregroundColor(.black)
                            .lineLimit(1)
                    } else if isLost {
                        Text("Status: Lost")
                            .font(.custom("Charter", size: 12))
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                            .lineLimit(1)
                    } else {
                        Text(description)
                            .font(.custom("Charter", size: 12))
                            .foregroundColor(.black)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .frame(width: 265, alignment: .leading)
                    }
                }
                .padding(.vertical, 8)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let fine = fine {
                        Text("₹\(String(format: "%.2f", fine))")
                            .font(.custom("Charter", size: 12))
                            .foregroundColor(.red)
                    }
                    
                    if showPlusButton {
                        Button(action: {
                            onPlusButtonTapped?()
                        }) {
                            Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle")
                                .foregroundColor(isAdded ? .green : .black)
                                .font(.system(size: 24))
                        }
                    } else if isLost {
                        Text("Lost")
                            .font(.custom("Charter", size: 14))
                            .foregroundColor(.red)
                            .fontWeight(.bold)
                    } else if let menuAction = menuAction {
                        Menu {
                            Button(role: .destructive) {
                                menuAction()
                            } label: {
                                Label("Mark as Lost", systemImage: "exclamationmark.triangle")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(.black)
                                .font(.system(size: 20))
                        }
                    } else {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.black)
                            .font(.system(size: 16))
                    }
                }
                .padding(.trailing, 8)
            }
            .frame(maxWidth: .infinity, maxHeight: 90)
        }
        .frame(maxWidth: .infinity, maxHeight: 90)
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .cornerRadius(0)
        .shadow(color: .black.opacity(0.5), radius: 0, x: 0, y: 1)
    }
}


// Preview
struct BookCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Normal book card
            BookCard(
                BookImage: "",
                title: "Great Gatsby",
                author: "F. Scott Fitzgerald",
                description: "Nick Carraway, a young man from Minnesota.",
                showPlusButton: false,
                onPlusButtonTapped: {},
                isAdded: false
            )
            
            // Lost book card
            BookCard(
                BookImage: "",
                title: "Moby Dick",
                author: "Herman Melville",
                description: "Call me Ishmael...",
                showPlusButton: false,
                isLost: true
            )
        }
        .padding()
    }
}
