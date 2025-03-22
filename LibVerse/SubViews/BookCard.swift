import SwiftUI

struct BookCard: View {
    let BookImage: String // This is a URL string
    let title: String
    let author: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center, spacing: 16) { // Align content vertically
                // Image container with fixed size and left padding
                ZStack {
                    // Rectangle border
                    Rectangle()
                        .stroke(Color.black, lineWidth: 0.5)
                        .frame(width: 44, height: 59)
                    
                    if BookImage.isEmpty {
                        Image("mvc")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 55)
                            .clipped()
                            .background(Color.white)
                    } else {
                        AsyncImage(url: URL(string: BookImage)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView() // Show a loading indicator
                                    .frame(width: 40, height: 55)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 55)
                                    .clipped()
                            case .failure:
                                Image("mvc") // Fallback image if URL fails to load
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 40, height: 55)
                                    .clipped()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                .frame(width: 44, height: 59) // Fixed size for the image container
                .padding(.leading, 35) // Add 10-point gap from the left edge
                
                // Text content (title, author, description)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.custom("sfpro", size: 14))
                        .lineLimit(1) // Ensure title doesn't wrap
                    
                    Text("By \(author)")
                        .font(.custom("sfpro", size: 10))
                        .foregroundColor(Color(.systemGray))
                        .italic()
                        .lineLimit(1) // Ensure author doesn't wrap
                    
                    Spacer().frame(height: 5)
                    
                    Text(description)
                        .font(.custom("sfpro", size: 10))
                        .foregroundColor(.black)
                        .lineLimit(2) // Limit description to 2 lines
                        .multilineTextAlignment(.leading)
                        .frame(width: 265, alignment: .leading) // Fixed width for description
                }
                .padding(.vertical, 8)
                
                // Chevron icon
                Spacer() // Push the chevron to the trailing edge
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
                    .padding(.trailing, 35)
            }
            .frame(height: 80) // Ensure the HStack has a fixed height
        }
        .frame(width: 393, height: 80, alignment: .center)
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
            description: "Nick Carraway, a young man from Minnesota,"
        )
        .padding()
    }
}
