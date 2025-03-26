//
//  CategoryBookView.swift
//  LibVerse
//
//  Created by Shahma Ansari on 23/03/25.
//

import SwiftUI

struct CategoryBooksView: View {
    let category: String
    let books: [Book]
    
    @Environment(\.presentationMode) var presentationMode
    
    var filteredBooks: [Book] {
        books.filter { $0.genre == category }
    }
    
    var body: some View {
        VStack {
            HStack(spacing: 0) {
                // Left Rectangle with back button
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
                
                // Right Rectangle with category text
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
                Text(category)
                    .font(.custom("Charter", size: 20))
                    .bold()
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .center), // Center the text
                alignment: .center
            )
            .frame(width: 400)
            .padding(.horizontal, -20)
            
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(filteredBooks) { book in
                        NavigationLink(destination: BookDetailView(book: book).environmentObject(SupabaseManager.shared)) {
                            BookCard(
                                BookImage: book.imageLink ?? "",
                                title: book.title,
                                author: book.author.joined(separator: ", "),
                                description: book.Description ?? "No description available"
                            )
                            .frame(width: 393, height: 90)
                            .padding(.vertical, 1)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255))
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .navigationTitle(category)
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
    }
    
}

struct CategoryBooksView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleBooks = [
            Book(
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
            ),
            Book(
                id: UUID(),
                title: "The Hobbit",
                author: ["J.R.R. Tolkien"],
                genre: "Fantasy",
                publicationDate: "1937-09-21",
                totalCopies: 8,
                availableCopies: 3,
                ISBN: "9780547928227",
                Description: "Bilbo Baggins is a hobbit who enjoys a comfortable, unambitious life, rarely traveling any farther than his pantry or cellar. But his contentment is disturbed when the wizard Gandalf and a company of dwarves arrive on his doorstep one day to whisk him away on an adventure.",
                shelfLocation: "A2",
                dateAdded: "2023-03-22",
                publisher: "Houghton Mifflin Harcourt",
                imageLink: "https://books.google.com/books/content?id=YyXoAAAACAAJ&printsec=frontcover&img=1&zoom=1&source=gbs_api"
            )
        ]
        
        return CategoryBooksView(
            category: "Fantasy", // Sample category
            books: sampleBooks // Sample books
        )
    }
}
