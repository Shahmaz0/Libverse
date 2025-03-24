//
//  SearchView.swift
//  LibVerse
//
//  Created by Astha Arora on 20/03/25.

import SwiftUI

struct SearchView: View {
    @StateObject private var dataController = DataController()
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var showSearchResults = false
    @State private var isSearchFieldFocused = false
    @State private var isSearchPageOpen = false
    
    var categories = [
        ("Technology", "chart.bar.fill"),
        ("Business", "building.2.fill"),
        ("Mathematics", "dollarsign.circle.fill"),
        ("Law", "book.fill"),
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 255/255, green: 243/255, blue: 230/255)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 16) {
                        if !isSearchFieldFocused {
                            Text("Search")
                                .font(.custom("sfprodisplaymedium", size: 28))
                                .padding(.horizontal)
                        }
                        
                        HStack(spacing: 0) {
                            TextField("Search by Title or author", text: $searchText, onEditingChanged: { editing in
                                isSearchFieldFocused = editing
                                if editing {
                                    isSearchPageOpen = true
                                }
                            })
                            .padding()
                            .frame(width: 360, height: 40)
                            .font(.custom("sfprodisplaymedium", size: 15))
                            .background(Color(red: 255/255, green: 239/255, blue: 210/255))
                            .cornerRadius(0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.black, lineWidth: 1.25)
                            )
                            .disabled(true) // Disable text input
                            .onTapGesture {
                                isSearchPageOpen = true // Open the full-screen search view
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color(red: 229/255, green: 122/255, blue: 65/255))
                    
                    // Categories List
                    if !isSearchFieldFocused {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(categories, id: \.0) { category, icon in
                                    NavigationLink(destination: CategoryBooksView(category: category, books: dataController.books)) {
                                        VStack(spacing: 0) {
                                            HStack {
                                                Image(systemName: icon)
                                                    .foregroundColor(.black)
                                                    .frame(width: 24, height: 24)
                                                Text(category)
                                                    .font(.custom("sfprodisplaymedium", size: 15))
                                                Spacer()
                                            }
                                            .padding(.vertical, 16)
                                            .padding(.horizontal)
                                            .contentShape(Rectangle()) // Ensure the entire row is tappable
                                        }
                                        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
                                    }
                                    .buttonStyle(PlainButtonStyle()) // Disable default row coloring
                                }
                            }
                        }
                        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                // Fetch books when the view appears
                dataController.fetchBooks()
            }
            .fullScreenCover(isPresented: $isSearchPageOpen, onDismiss: {
                isSearchFieldFocused = false
                isSearchPageOpen = false
            }) {
                FullScreenSearchView(
                    searchText: $searchText,
                    isSearchPageOpen: $isSearchPageOpen,
                    books: dataController.books // Pass the books array
                )
            }
        }
    }
}

struct FullScreenSearchView: View {
    @Binding var searchText: String
    @Binding var isSearchPageOpen: Bool
    let books: [Book] // Books passed from SearchView
    
    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return books // Show all books if search text is empty
        } else {
            return books.filter { book in
                // Check if the title contains the search text
                let titleMatch = book.title.localizedCaseInsensitiveContains(searchText)
                
                // Check if any author in the array contains the search text
                let authorMatch = book.author.contains { author in
                    author.localizedCaseInsensitiveContains(searchText)
                }
                
                // Return true if either title or author matches
                return titleMatch || authorMatch
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 255/255, green: 239/255, blue: 210/255)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        ZStack(alignment: .leading) {
                            TextField("", text: $searchText)
                                .padding(.horizontal, 16)
                                .frame(height: 40)
                                .foregroundColor(.black)
                                .font(.custom("sfprodisplaymedium", size: 15))
                                .background(Color(red: 255/255, green: 239/255, blue: 210/255))
                                .cornerRadius(0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.black, lineWidth: 1.25)
                                )
                            
                            // Placeholder
                            if searchText.isEmpty {
                                Text("Search by Title or author")
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 16)
                                    .font(.custom("sfprodisplaymedium", size: 15))
                                    .allowsHitTesting(false)
                            }
                        }
                        
                        Button(action: {
                            isSearchPageOpen = false
                        }) {
                            Text("Cancel")
                                .font(.custom("sfprodisplaymedium", size: 15))
                                .foregroundColor(.black)
                        }
                    }
                    .padding()
                    .background(Color(red: 255/255, green: 239/255, blue: 210/255))
                    
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(filteredBooks, id: \.id) { book in
                                NavigationLink(destination: BookDetailView(book: book).environmentObject(SupabaseManager.shared)) {
                                    BookCard(
                                        BookImage: book.imageLink ?? "mvc",
                                        title: book.title,
                                        author: book.author.joined(separator: ", "),
                                        description: book.Description ?? "No description available"
                                    )
                                    .frame(width: 393, height: 80)
                                    .padding(.vertical, 1)
                                }
                                .buttonStyle(PlainButtonStyle()) // Remove default button styling
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true) // Hide the navigation bar in the full-screen view
        }
    }
}

//#Preview {
//    FullScreenSearchView(searchText: .constant(""), isSearchPageOpen: .constant(true))
//}


#Preview{
    SearchView()
}
