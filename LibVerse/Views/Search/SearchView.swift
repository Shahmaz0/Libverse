//
//  SearchView.swift
//  LibVerse
//
//  Created by Astha Arora on 20/03/25.

import SwiftUI

struct SearchView: View {
    @StateObject private var dataController = DataController()
    @State private var searchText = ""
    @State private var isSearching = false
    @FocusState private var isSearchFieldFocused: Bool
    @State private var selectedBook: Book? = nil
    
    let categories = [
        ("Technology", "chart.bar.fill"),
        ("Business", "building.2.fill"),
        ("Mathematics", "dollarsign.circle.fill"),
        ("Law", "book.fill"),
    ]
    
    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return dataController.books
        } else {
            return dataController.books.filter { book in
                let titleMatch = book.title.localizedCaseInsensitiveContains(searchText)
                let authorMatch = book.author.contains { $0.localizedCaseInsensitiveContains(searchText) }
                return titleMatch || authorMatch
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background color
                Color(red: 255/255, green: 243/255, blue: 230/255)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Search Header
                    VStack(alignment: .leading, spacing: 16) {
                        if !isSearching {
                            Text("Search")
                                .font(.custom("sfprodisplaymedium", size: 28))
                                .padding(.horizontal)
                        }
                        
                        HStack(spacing: 0) {
                            TextField("Search by Title or author", text: $searchText) { editing in
                                withAnimation {
                                    isSearching = editing
                                }
                            }
                            .focused($isSearchFieldFocused)
                            .padding()
                            .frame(height: 40)
                            .font(.custom("sfprodisplaymedium", size: 15))
                            .background(Color(red: 255/255, green: 239/255, blue: 210/255))
                            .cornerRadius(0)
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.black, lineWidth: 1.25)
                            )
                            
                            if isSearching {
                                Button("Cancel") {
                                    withAnimation {
                                        searchText = ""
                                        isSearching = false
                                        isSearchFieldFocused = false
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                    }
                                }
                                .font(.custom("sfprodisplaymedium", size: 15))
                                .foregroundColor(.black)
                                .padding(.leading, 8)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color(red: 229/255, green: 122/255, blue: 65/255))
                    
                    // Content Area
                    ScrollView {
                        if isSearching {
                            // Show search results
                            LazyVStack(spacing: 0) {
                                ForEach(filteredBooks, id: \.id) { book in
                                    Button(action: {
                                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                        selectedBook = book
                                    }) {
                                        BookCard(
                                            BookImage: book.imageLink ?? "mvc",
                                            title: book.title,
                                            author: book.author.joined(separator: ", "),
                                            description: book.Description ?? "No description available"
                                        )
                                        .frame(width: 393, height: 80)
                                        .padding(.vertical, 1)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        } else {
                            // Show categories
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
                                        }
                                        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                    }
                    .background(Color(red: 255/255, green: 239/255, blue: 210/255))
                }
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(
                    destination: selectedBook != nil ? AnyView(BookDetailView(book: selectedBook!).environmentObject(SupabaseManager.shared)) : AnyView(EmptyView()),
                    isActive: Binding(
                        get: { selectedBook != nil },
                        set: { newValue in
                            if !newValue {
                                selectedBook = nil
                            }
                        }
                    )
                ) {
                    EmptyView()
                }
            )
            .onAppear {
                dataController.fetchBooks()
            }
        }
    }
}
//#Preview {
//    FullScreenSearchView(searchText: .constant(""), isSearchPageOpen: .constant(true))
//}


#Preview{
    SearchView()
}
