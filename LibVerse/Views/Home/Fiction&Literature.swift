//
//  Fiction&Literature.swift
//  LibVerse
//
//  Created by Piyush on 01/04/25.
//

import Foundation
import SwiftUI

// MARK: - Fiction & Literature View
struct FictionLiteratureView: View {
    @State private var searchText = ""
    @State private var books: [LibraryBook] = []
    @State private var isLoading = true
    @State private var error: String?
    @State private var selectedGenre = 0 // 0 for Fiction, 1 for Literature
    @Environment(\.presentationMode) var presentationMode
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var filteredBooks: [LibraryBook] {
        if searchText.isEmpty {
            return books
        }
        return books.filter { book in
            book.title.lowercased().contains(searchText.lowercased()) ||
            book.author.lowercased().contains(searchText.lowercased())
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search books...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()
            .background(Color(hex: "FDE9C2"))
            
            // Genre Selector
            Picker("Genre", selection: $selectedGenre) {
                Text("Fiction").tag(0)
                Text("Literature").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedGenre) { _ in
                fetchBooks()
            }
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.2)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = error {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            } else if books.isEmpty {
                Text("No books available")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 24) {
                        ForEach(filteredBooks) { book in
                            BookGridItem(book: book)
                                .frame(height: 220) // Fixed height for consistency
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                }
            }
        }
        .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
        .navigationTitle(selectedGenre == 0 ? "Fiction" : "Literature")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
        }
        .onAppear {
            fetchBooks()
        }
    }
    
    private func fetchBooks() {
        isLoading = true
        error = nil
        books = [] // Clear existing books
        
        Task {
            do {
                let genre = selectedGenre == 0 ? "Fiction" : "Literature"
                print("Fetching \(genre) books from Supabase...")
                
                let response: [LibraryBook] = try await SupabaseManager.shared.client
                    .from("Books")
                    .select("*")
                    .eq("genre", value: genre)
                    .order("title")
                    .execute()
                    .value
                
                DispatchQueue.main.async {
                    self.books = response
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = "Failed to load books: \(error.localizedDescription)"
                    self.isLoading = false
                }
            }
        }
    }
}

// MARK: - Book Grid Item
struct BookGridItem: View {
    let book: LibraryBook
    
    var body: some View {
        NavigationLink(destination: BookDetailView(book: Book(from: book))) {
            VStack(alignment: .center, spacing: 8) {
                // Book Cover
                ZStack {
                    Rectangle()
                        .stroke(Color.black, lineWidth: 1)
                        .frame(width: 110, height: 140)
                    
                    if let imageUrl = book.imageLink, !imageUrl.isEmpty {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Color.gray.opacity(0.3)
                        }
                        .frame(width: 105, height: 135)
                        .clipped()
                        .background(Color.white)
                    } else {
                        Image(systemName: "book.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50)
                            .foregroundColor(.gray)
                            .frame(width: 105, height: 135)
                            .background(Color.white)
                    }
                }
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                
                // Book Title
                Text(book.title)
                    .font(.custom("Charter", size: 14))
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.black)
                
                // Author
                Text(book.author)
                    .font(.custom("Charter", size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
    }
}
