//
//  AddBooksToShelf.swift
//  LibVerse
//
//  Created by Piyush on 31/03/25.
//

import Foundation
import SwiftUI

struct AddBooksToShelf: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    @StateObject private var dataController = DataController()
    @Binding var shelfBooks: [String: [Book]]
    let selectedCategory: String
    var onBookSelected: (Book) -> Void
    
    // Add state to track which books are in the shelf
    @State private var addedBooks: Set<UUID> = []
    
    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return dataController.books
        } else {
            return dataController.books.filter { book in
                let titleMatch = book.title.localizedCaseInsensitiveContains(searchText)
                let authorMatch = book.author.contains { author in
                    author.localizedCaseInsensitiveContains(searchText)
                }
                return titleMatch || authorMatch
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color(hex: "FCEFD5")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(Color(hex: "875232"))
                        .padding(.leading, 10)
                    
                    TextField("Search books...", text: $searchText)
                        .font(.custom("Charter", size: 16))
                        .padding(.vertical, 12)
                }
                .background(Color(hex: "FCEFD5"))
                .overlay(
                    Rectangle()
                        .stroke(Color.black, lineWidth: 1)
                )
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Search Results
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredBooks, id: \.id) { book in
                            BookCard(
                                BookImage: book.imageLink ?? "mvc",
                                title: book.title,
                                author: book.author.joined(separator: ", "),
                                description: book.Description ?? "No description available",
                                showPlusButton: true,
                                onPlusButtonTapped: {
                                    if addedBooks.contains(book.id) {
                                        addedBooks.remove(book.id)
                                    } else {
                                        addedBooks.insert(book.id)
                                        onBookSelected(book)
                                        dismiss()
                                    }
                                },
                                isAdded: addedBooks.contains(book.id)
                            )
                            .padding(.vertical, 1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            dataController.fetchBooks()
            // Initialize addedBooks with books that are already in the shelf
            if let currentShelfBooks = shelfBooks[selectedCategory] {
                addedBooks = Set(currentShelfBooks.map { $0.id })
            }
        }
    }
}
