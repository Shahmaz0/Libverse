//
//  SearchResultView.swift
//  LibVerse
//
//  Created by Shahma Ansari on 20/03/25.
//

import SwiftUI

struct SearchResultView: View {
    let searchText: String
    let selectedCategory: String?
    @ObservedObject var dataController: DataController
    
    // Computed property to filter books
    var filteredBooks: [Book] {
        dataController.books.filter { book in
            let matchesSearchText = searchText.isEmpty ||
                book.title.localizedCaseInsensitiveContains(searchText) ||
            book.author.contains{$0.localizedCaseInsensitiveContains(searchText)}
            
            let matchesCategory = selectedCategory == nil ||
            book.genre == selectedCategory
            
            return matchesSearchText && matchesCategory
        }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    // Use the filteredBooks property
                    ForEach(filteredBooks, id: \.id) { book in
                        BookCard(
                            BookImage: book.imageLink,
                            title: book.title,
                            author: book.author.joined(separator: ", "),
                            description: book.Description
                        )
                        .padding()
                    }
                }
                .background(Color(red: 252/255, green: 240/255, blue: 218/255))
            }
            .navigationTitle("Search Results")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarHidden(true)
        }
        .background(Color(red: 252/255, green: 240/255, blue: 218/255))
    }
}
