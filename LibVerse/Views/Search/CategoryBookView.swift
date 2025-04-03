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
