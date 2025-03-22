//
//  SearchResultView.swift
//  LibVerse
//
//  Created by Shahma Ansari on 20/03/25.
//

import SwiftUI

struct SearchResultView: View {
    @Binding var searchText: String
    var selectedCategory: String?
    @ObservedObject var dataController: DataController
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack(spacing: 0) {
                TextField("Search by Title or author", text: $searchText)
                    .padding()
                    .frame(height: 40)
                    .font(.custom("sfprodisplaymedium", size: 15))
                    .background(Color(red: 255/255, green: 243/255, blue: 230/255))
                    .cornerRadius(0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.black, lineWidth: 1.25)
                    )
                    .onChange(of: searchText) { _ in
                        dataController.updateSuggestions(for: searchText)
                    }
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                    }
                    .frame(width: 30, height: 40)
                    .padding(.horizontal, 16)
                    .background(Color(red: 255/255, green: 243/255, blue: 230/255))
                    .foregroundColor(.black)
                    .cornerRadius(0)
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.black, lineWidth: 1.25)
                    )
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            
            // Search Results
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(dataController.suggestions, id: \.id) { book in
                        BookCard(
                            BookImage: book.imageLink,
                            title: book.title,
                            author: book.author.joined(separator: ", "),
                            description: book.Description
                        )
                        .padding(.vertical, 8)
                    }
                }
            }
            .background(Color(red: 255/255, green: 243/255, blue: 230/255))
        }
        .navigationBarTitle("Search", displayMode: .inline)
        .background(Color(red: 255/255, green: 243/255, blue: 230/255))
    }
}
