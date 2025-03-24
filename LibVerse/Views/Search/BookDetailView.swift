//
//  BookDetailView.swift
//  LibVerse
//
//  Created by Shahma Ansari on 23/03/25.
//

import SwiftUI

struct BookDetailView: View {
    let book: Book
    @Environment(\.presentationMode) var presentationMode
    @State private var isFavorite: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                // Top Navigation Bar
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
                        .frame(width: 65, height: 60)
                        .overlay(
                            Rectangle()
                                .frame(height: 1.25)
                                .foregroundColor(.black)
                                .padding(.top, -1),
                            alignment: .top
                        )
                        .overlay(
                            Rectangle()
                                .frame(width: 1.25)
                                .foregroundColor(.black)
                                .padding(.trailing, -1),
                            alignment: .trailing
                        )
                        .overlay(
                            Rectangle()
                                .frame(height: 1.25)
                                .foregroundColor(.black)
                                .padding(.bottom, -1),
                            alignment: .bottom
                        )
                        .overlay(
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Image(systemName: "arrow.left")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.black)
                            }
                            .padding(.leading, 20),
                            alignment: .leading
                        )
                    
                    Rectangle()
                        .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
                        .frame(maxWidth: .infinity, maxHeight: 60)
                        .overlay(
                            Rectangle()
                                .frame(height: 1.25)
                                .foregroundColor(.black)
                                .padding(.top, -1),
                            alignment: .top
                        )
                        .overlay(
                            Rectangle()
                                .frame(width: 1.25)
                                .foregroundColor(.black)
                                .padding(.leading, -1),
                            alignment: .leading
                        )
                        .overlay(
                            Rectangle()
                                .frame(height: 1.25)
                                .foregroundColor(.black)
                                .padding(.bottom, -1),
                            alignment: .bottom
                        )
                        
                }
                .overlay(
                    Text("Book Details")
                        .font(.custom("Charter", size: 20))
                        .bold()
                        .foregroundColor(.black),
                    alignment: .center
                )
                .frame(width: 400)
                .padding(.horizontal, -20)
                
                // Book Image and Title Section
                HStack(alignment: .top, spacing: 16) {
                    ZStack {
                        Rectangle()
                            .stroke(Color.black, lineWidth: 0.5)
                            .frame(width: 120, height: 120)

                        if book.imageLink?.isEmpty ?? true {
                            Image("mvc")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 110, height: 110)
                                .background(Color.white)
                                .clipped()
                        } else {
                            AsyncImage(url: URL(string: book.imageLink!)) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 112, height: 112)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 112, height: 112)
                                        .clipped()
                                case .failure:
                                    Image("mvc")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 112, height: 112)
                                        .clipped()
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }
                    }
                    .frame(width: 120, height: 120)
                    .padding(.leading, 5)

                    VStack(alignment: .leading, spacing: 10) {
                        Text(book.title)
                            .font(.custom("Charter", size: 15))
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("By: \(book.author.joined(separator: ", "))")
                            .font(.custom("Charter", size: 13))
                            .foregroundColor(.gray)

                        // Heart Button Positioned Properly
                        Button(action: {
                            isFavorite.toggle()
                        }) {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .foregroundColor(.black)
                        }
                        .padding(.top, 8) // Remove negative padding to improve tap area
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal)

                // Divider
                Rectangle()
                    .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
                    .frame(width: 365, height: 1)
                    .overlay(
                        Rectangle()
                            .frame(height: 1.25)
                            .foregroundColor(.black)
                            .padding(.top, -1),
                        alignment: .top
                    )
                
                // Book Details Section
                VStack(alignment: .leading, spacing: 10) {
                    // Genre
                    HStack(alignment: .top, spacing: 10) {
                        Text("Genre")
                            .font(.custom("Charter", size: 14))
                            .foregroundColor(.black)
                            .frame(width: 120, alignment: .leading) // Fixed width for labels
                        
                        Text(book.genre)
                            .font(.custom("Charter", size: 14))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading) // Take remaining space
                    }
                    
                    // Shelf Location
                    HStack(alignment: .top, spacing: 10) {
                        Text("Shelf Location")
                            .font(.custom("Charter", size: 14))
                            .foregroundColor(.black)
                            .frame(width: 120, alignment: .leading)
                        
                        Text(book.shelfLocation ?? "N/A")
                            .font(.custom("Charter", size: 14))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Available Copies
                    HStack(alignment: .top, spacing: 10) {
                        Text("Available Copies")
                            .font(.custom("Charter", size: 14))
                            .foregroundColor(.black)
                            .frame(width: 120, alignment: .leading)
                        
                        Text("\(book.availableCopies)")
                            .font(.custom("Charter", size: 14))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Publisher
                    HStack(alignment: .top, spacing: 10) {
                        Text("Publisher")
                            .font(.custom("Charter", size: 14))
                            .foregroundColor(.black)
                            .frame(width: 120, alignment: .leading)
                        
                        Text(book.publisher ?? "N/A")
                            .font(.custom("Charter", size: 14))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    
                    // Released
                    HStack(alignment: .top, spacing: 10) {
                        Text("Released")
                            .font(.custom("Charter", size: 14))
                            .foregroundColor(.black)
                            .frame(width: 120, alignment: .leading)
                        
                        Text(book.publicationDate)
                            .font(.custom("Charter", size: 14))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.leading, 20) // Add leading padding for alignment
                .frame(maxWidth: .infinity, alignment: .leading) // Ensure the VStack takes full width
                
                // Divider
                Rectangle()
                    .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
                    .frame(width: 365, height: 1)
                    .overlay(
                        Rectangle()
                            .frame(height: 1.25)
                            .foregroundColor(.black)
                            .padding(.top, -1),
                        alignment: .top
                    )
                
                // Description
                Text(book.Description ?? "No description available")
                    .font(.custom("Charter", size: 13))
                    .foregroundColor(.black)
                    .lineLimit(nil)
                    .padding(.horizontal)
                    .frame(width: 400, alignment: .center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top)
        }
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
        .navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
        .edgesIgnoringSafeArea(.bottom)
    }
}

#Preview {
    let sampleBook = Book(
        id: UUID(),
        title: "Harry Potter and the Sorcerer's Stone",
        author: ["J.K. Rowling"],
        genre: "Fantasy",
        publicationDate: "1997-06-26",
        totalCopies: 10,
        availableCopies: 5,
        ISBN: "9780590353427",
        Description: "Die-hard Harry Potter audiobook fans will list the ways in which Dale differs from Fry. We love both of their performances, but some fans are firmly Team Dale or Team Fry. There's so much to love about Dale's interpretation in the U.S. edition of the audiobooks. From his voicing of a whiny Draco to the wispy, heartless tones of Voldemort, he gives each character a life of their own.",
        shelfLocation: "A1",
        dateAdded: "2023-03-21",
        publisher: "Audible Verse, Inc.",
        imageLink: "https://books.google.com/books/content?id=hjEFCAAAQBAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api"
    )
    return BookDetailView(book: sampleBook)
}

//Narrator
//Text("Narrator: Jim Dale")
//    .font(.custom("sfprodisplaymedium", size: 16))
//    .foregroundColor(.black)
//
//// Divider
//Divider()
//    .background(Color.gray.opacity(0.3))
//
//// Read Free For 30 Days
//Text("Read Free For 30 Days")
//    .font(.custom("sfprodisplaymedium", size: 20))
//    .foregroundColor(.black)
//
//// Play Sample Button
//Button(action: {
//    // Action to play sample
//}) {
//    Text("Play Sample")
//        .font(.custom("sfprodisplaymedium", size: 18))
//        .foregroundColor(.white)
//        .padding()
//        .frame(maxWidth: .infinity)
//        .background(Color.blue)
//        .cornerRadius(8)
//}
//
//// Download, Save, Add to List
//HStack {
//    Button(action: {
//        // Action for Download
//    }) {
//        Text("Download")
//            .font(.custom("sfprodisplaymedium", size: 16))
//            .foregroundColor(.blue)
//    }
//    Spacer()
//    Button(action: {
//        // Action for Save
//    }) {
//        Text("Save")
//            .font(.custom("sfprodisplaymedium", size: 16))
//            .foregroundColor(.blue)
//    }
//    Spacer()
//    Button(action: {
//        // Action for Add to List
//    }) {
//        Text("Add to List")
//            .font(.custom("sfprodisplaymedium", size: 16))
//            .foregroundColor(.blue)
//    }
//}
//.padding(.vertical)
//
//// Rating, Length, Format, Publisher, Released
//VStack(alignment: .leading, spacing: 8) {
//    HStack {
//        Text("Rating ★★★★★(1.5K)")
//            .font(.custom("sfprodisplaymedium", size: 16))
//            .foregroundColor(.black)
//        Spacer()
//    }
//    
//    HStack {
//        Text("Length 22 hr 56 min")
//            .font(.custom("sfprodisplaymedium", size: 16))
//            .foregroundColor(.black)
//        Spacer()
//    }
//    
//    HStack {
//        Text("Format Audiobook")
//            .font(.custom("sfprodisplaymedium", size: 16))
//            .foregroundColor(.black)
//        Spacer()
//    }
//    
//    HStack {
//        Text("Publisher Audible Verse, Inc.")
//            .font(.custom("sfprodisplaymedium", size: 16))
//            .foregroundColor(.black)
//        Spacer()
//    }
//    
//    HStack {
//        Text("Released Apr 24, 2022")
//            .font(.custom("sfprodisplaymedium", size: 16))
//            .foregroundColor(.black)
//        Spacer()
//    }
//}
//
//// Description
//Text(book.Description ?? "No description available")
//    .font(.custom("sfprodisplaymedium", size: 16))
//    .foregroundColor(.black)
//    .lineLimit(nil)
