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
        ("Technology", "Technology"),
        ("Business", "Business"),
        ("Mathematics", "Mathematic"),
        ("Law", "Law"),
        ("Medicine", "Medicine"),
        ("Fiction", "Fiction"),
        ("Non-Fiction", "NonFiction"),
        ("Literature", "Literature")
    ]
    
    private func normalizeText(_ text: String) -> String {
        return text
            .lowercased()
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "[,'\";:.!?]", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
    }
    
    private func bookMatchesSearch(_ book: Book, searchTerms: [String]) -> Bool {
        guard !searchTerms.isEmpty else { return true }
        
        let normalizedTitle = normalizeText(book.title)
        let normalizedAuthors = book.author.map { normalizeText($0) }
        let normalizedDescription = book.Description.map { normalizeText($0) } ?? ""
        
        for term in searchTerms {
            let normalizedTerm = normalizeText(term)
            guard !normalizedTerm.isEmpty else { continue }
            
            // Check title
            if normalizedTitle.contains(normalizedTerm) {
                return true
            }
            
            // Check authors
            if normalizedAuthors.contains(where: { $0.contains(normalizedTerm) }) {
                return true
            }
            
            // Check description
            if normalizedDescription.contains(normalizedTerm) {
                return true
            }
            
            // Check if search term matches beginning of any word
            let titleWords = normalizedTitle.components(separatedBy: " ")
            if titleWords.contains(where: { $0.hasPrefix(normalizedTerm) }) {
                return true
            }
            
            // Check author words
            for author in normalizedAuthors {
                let authorWords = author.components(separatedBy: " ")
                if authorWords.contains(where: { $0.hasPrefix(normalizedTerm) }) {
                    return true
                }
            }
        }
        
        return false
    }
    
    var filteredBooks: [Book] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return dataController.books
        } else {
            let searchTerms = normalizeText(searchText)
                .components(separatedBy: " ")
                .filter { !$0.isEmpty }
            
            return dataController.books.filter { book in
                bookMatchesSearch(book, searchTerms: searchTerms)
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
                            // Show categories as grid
                            VStack(spacing: 20) {
                                ForEach(0..<4) { row in
                                    HStack(spacing: 16) {
                                        ForEach(0..<2) { col in
                                            let index = row * 2 + col
                                            if index < categories.count {
                                                let (category, icon) = categories[index]
                                                NavigationLink(destination: CategoryBooksView(category: category, books: dataController.books)) {
                                                    ZStack {
                                                        Image(icon)
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width: 172, height: 70)
                                                            .clipped()
                                                            .overlay(
                                                                RoundedRectangle(cornerRadius: 0)
                                                                    .stroke(Color.black, lineWidth: 1)
                                                            )
                                                        
                                                     
                                                    }
                                                }
                                                .buttonStyle(PlainButtonStyle())
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(20)
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
