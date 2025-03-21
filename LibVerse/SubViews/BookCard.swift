import SwiftUI

import SwiftUI

struct BookCard: View {
    let BookImage: String // This is a URL string
    let title: String
    let author: String
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 16) {
                ZStack {
                    // Rectangle border
                    Rectangle()
                        .stroke(Color.black, lineWidth: 1.5)
                        .frame(width: 88, height: 135)
                    
                    // Load image from URL using AsyncImage
                    if BookImage.isEmpty {
                        // Fallback image if URL is empty
                        Image("mvc") // Replace "mvc" with your fallback image name
                            .resizable()
                            .scaledToFill()
                            .frame(width: 87, height: 135)
                            .clipped()
                            .background(Color.white)
                    } else {
                        AsyncImage(url: URL(string: BookImage)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView() // Show a loading indicator
                                    .frame(width: 87, height: 135)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 87, height: 135)
                                    .clipped()
                            case .failure:
                                Image("mvc") // Fallback image if URL fails to load
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 87, height: 135)
                                    .clipped()
                            @unknown default:
                                EmptyView()
                            }
                        }
                    }
                }
                
                // Book details
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.custom("Menlo", size: 16))
                    
                    Text("By \(author)")
                        .font(.custom("Menlo", size: 12))
                        .italic()
                        .foregroundColor(.black)
                    
                    Spacer().frame(height: 8)
                    
                    Text(description)
                        .font(.custom("Menlo", size: 10))
                        .foregroundColor(.black)
                        .lineLimit(7)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 8)
                
                Spacer()
            }
            .padding(.horizontal, 16)
            
            // Reserve button
            HStack {
                Spacer()
                Button(action: {
                    print("Reserve button tapped")
                }) {
                    Text("Reserve")
                        .frame(width: 345, height: 49)
                        .background(Color(red: 255/255, green: 111/255, blue: 49/255))
                        .foregroundColor(.white)
                        .font(.headline)
                        .overlay(
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color.black, lineWidth: 1.25)
                        )
                }
                Spacer()
            }
            .padding(.top, 16)
        }
        .frame(width: 404, height: 250)
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .cornerRadius(0)
        .shadow(color: .black.opacity(0.5), radius: 0, x: 0, y: 1)
        .navigationBarTitleDisplayMode(.inline)
    }
}// Preview
struct BookCard_Previews: PreviewProvider {
    static var previews: some View {
        BookCard(
            BookImage: "",
            title: "The Great Gatsby",
            author: "F. Scott Fitzgerald",
            description: "Nick Carraway, a young man from Minnesota, moves to New York in the summer of the 1922 to learn about the bond business. He rents house in the West Egg district of Long Island, a wealthy but unfashionable area populated by the new rich, a group who ..."
        )
        .padding()
    }
}
