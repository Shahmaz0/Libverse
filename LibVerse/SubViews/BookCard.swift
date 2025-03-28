import SwiftUI

struct BookCard: View {
    let BookImage: String // This is a URL string
    let title: String
    let author: String
    let description: String
    var showPlusButton: Bool = false // New parameter with default value false
    var onPlusButtonTapped: (() -> Void)? = nil // New parameter for handling plus button tap
    var isAdded: Bool = false // Changed to regular Bool with default value
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 16) {
                ZStack {
                    Rectangle()
                        .stroke(Color.black, lineWidth: 0.5)
                        .frame(width: 50, height: 65)
                    
                    if BookImage.isEmpty {
                        Image("mvc")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 45, height: 60)
                            .clipped()
                            .background(Color.white)
                    } else {
                        AsyncImage(url: URL(string: BookImage)) { phase in
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
                    }
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
                    
                    Text(description)
                        .font(.custom("Charter", size: 12))
                        .foregroundColor(.black)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .frame(width: 265, alignment: .leading)
                }
                .padding(.vertical, 8)
                
                Spacer()
                if showPlusButton {
                    Button(action: {
                        onPlusButtonTapped?()
                    }) {
                        Image(systemName: isAdded ? "checkmark.circle.fill" : "plus.circle")
                            .foregroundColor(isAdded ? .green : .black)
                            .font(.system(size: 24))
                    }
                    .padding(.leading, -35)
                } else {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                        .padding(.leading, -35)
                }
            }
            .frame(height: 90)
        }
        .frame(width: 393, height: 90, alignment: .center)
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .cornerRadius(0)
        .shadow(color: .black.opacity(0.5), radius: 0, x: 0, y: 1)
    }
}


// Preview
struct BookCard_Previews: PreviewProvider {
    static var previews: some View {
        BookCard(
            BookImage: "",
            title: "Great Gatsby",
            author: "F. Scott Fitzgerald",
            description: "Nick Carraway, a young man from Minnesota.",
            isAdded: false
        )
        .padding()
    }
}
