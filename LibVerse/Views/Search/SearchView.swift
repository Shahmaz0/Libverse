//
//  SearchView.swift
//  LibVerse
//
//  Created by Astha Arora on 20/03/25.

import SwiftUI

//Book(title: "The Great Gatsby", author: "F. Scott Fitzgerald", description: "Nick Carraway, a young man from Minnesota, moves to New York in the summer of the 1922 to learn about the bond business.", category: "Contemporary Fiction", image: "book1"),
//Book(title: "To Kill a Mockingbird", author: "Harper Lee", description: "The story of a young girl and her family in the American South during the 1930s.", category: "Contemporary Fiction", image: "book2"),
//Book(title: "1984", author: "George Orwell", description: "A dystopian novel set in a totalitarian society ruled by the Party.", category: "Politics", image: "book3"),


struct SearchView: View {
    @StateObject private var dataController = DataController()
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var showSearchResults = false
    @State private var isSearchFieldFocused = false
    @State private var isSearchPageOpen = false // For full-screen search view
    
    var categories = [
        ("Career & Growth", "chart.bar.fill"),
        ("Business", "building.2.fill"),
        ("Finance & Money Management", "dollarsign.circle.fill"),
        ("Contemporary Fiction", "book.fill"),
        ("Romance", "heart.fill"),
        ("Politics", "building.columns.fill"),
        ("Mystery & Crime Fiction", "questionmark.circle.fill"),
        ("Sport & Recreation", "sportscourt.fill"),
        ("Social Science", "person.2.fill")
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
                    .background(Color(red: 244/255, green: 221/255, blue: 93/255))
                    
                    // Categories List
                    if !isSearchFieldFocused {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(categories, id: \.0) { category, icon in
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
                                        .background(selectedCategory == category ? Color.orange.opacity(0.3) : Color.clear)
                                        .onTapGesture {
                                            selectedCategory = category
                                        }
                                        
                                        Divider()
                                            .background(Color.black.opacity(0.2))
                                    }
                                    .background(Color(red: 255/255, green: 239/255, blue: 210/255))
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
                isSearchFieldFocused = false // Reset the focus state when the full-screen view is dismissed
                isSearchPageOpen = false // Ensure the search page is closed
            }) {
                FullScreenSearchView(searchText: $searchText, isSearchPageOpen: $isSearchPageOpen)
            }
        }
    }
}

struct FullScreenSearchView: View {
    @Binding var searchText: String
    @Binding var isSearchPageOpen: Bool
    
    let books: [Book] = [
        Book(
            id: UUID(),
            title: "The Great Gatsby",
            author: ["F. Scott Fitzgerald"],
            genre: "Classic",
            publicationDate: "1925-04-10",
            totalCopies: 10,
            availableCopies: 7,
            ISBN: "9780743273565",
            Description: "A story of the fabulously wealthy Jay Gatsby and his love for the beautiful Daisy Buchanan.",
            shelfLocation: "Fiction A1",
            dateAdded: "2023-01-15",
            publisher: "Scribner",
            imageLink: "https://example.com/great-gatsby.jpg"
        ),
        Book(
            id: UUID(),
            title: "To Kill a Mockingbird",
            author: ["Harper Lee"],
            genre: "Classic",
            publicationDate: "1960-07-11",
            totalCopies: 8,
            availableCopies: 5,
            ISBN: "9780061120084",
            Description: "The story of a young girl and her family in the American South during the 1930s.",
            shelfLocation: "Fiction A2",
            dateAdded: "2023-02-20",
            publisher: "J.B. Lippincott & Co.",
            imageLink: "https://example.com/mockingbird.jpg"
        ),
        Book(
            id: UUID(),
            title: "1984",
            author: ["George Orwell"],
            genre: "Dystopian",
            publicationDate: "1949-06-08",
            totalCopies: 12,
            availableCopies: 3,
            ISBN: "9780451524935",
            Description: "A dystopian novel set in a totalitarian society ruled by the Party.",
            shelfLocation: "Fiction B1",
            dateAdded: "2023-03-05",
            publisher: "Secker & Warburg",
            imageLink: "https://example.com/1984.jpg"
        ),
        Book(
            id: UUID(),
            title: "Pride and Prejudice",
            author: ["Jane Austen"],
            genre: "Romance",
            publicationDate: "1813-01-28",
            totalCopies: 15,
            availableCopies: 10,
            ISBN: "9780141439518",
            Description: "A romantic novel of manners that follows the character development of Elizabeth Bennet.",
            shelfLocation: "Fiction C1",
            dateAdded: "2023-04-10",
            publisher: "T. Egerton, Whitehall",
            imageLink: "https://example.com/pride-prejudice.jpg"
        ),
        Book(
            id: UUID(),
            title: "The Catcher in the Rye",
            author: ["J.D. Salinger"],
            genre: "Coming-of-Age",
            publicationDate: "1951-07-16",
            totalCopies: 9,
            availableCopies: 4,
            ISBN: "9780316769488",
            Description: "A story about the protagonist Holden Caulfield's experiences in New York City.",
            shelfLocation: "Fiction D1",
            dateAdded: "2023-05-12",
            publisher: "Little, Brown and Company",
            imageLink: "https://example.com/catcher-rye.jpg"
        ),
        Book(
            id: UUID(),
            title: "The Hobbit",
            author: ["J.R.R. Tolkien"],
            genre: "Fantasy",
            publicationDate: "1937-09-21",
            totalCopies: 20,
            availableCopies: 15,
            ISBN: "9780547928227",
            Description: "A fantasy novel about the adventures of Bilbo Baggins in Middle-earth.",
            shelfLocation: "Fantasy A1",
            dateAdded: "2023-06-18",
            publisher: "George Allen & Unwin",
            imageLink: "https://example.com/hobbit.jpg"
        ),
        Book(
            id: UUID(),
            title: "The Lord of the Rings",
            author: ["J.R.R. Tolkien"],
            genre: "Fantasy",
            publicationDate: "1954-07-29",
            totalCopies: 18,
            availableCopies: 12,
            ISBN: "9780618640157",
            Description: "An epic high-fantasy novel about the quest to destroy the One Ring.",
            shelfLocation: "Fantasy A2",
            dateAdded: "2023-07-22",
            publisher: "George Allen & Unwin",
            imageLink: "https://example.com/lotr.jpg"
        ),
        Book(
            id: UUID(),
            title: "Harry Potter and the Philosopher's Stone",
            author: ["J.K. Rowling"],
            genre: "Fantasy",
            publicationDate: "1997-06-26",
            totalCopies: 25,
            availableCopies: 20,
            ISBN: "9780747532743",
            Description: "The first book in the Harry Potter series, following the young wizard Harry Potter.",
            shelfLocation: "Fantasy B1",
            dateAdded: "2023-08-30",
            publisher: "Bloomsbury",
            imageLink: "https://example.com/hp-philosophers-stone.jpg"
        ),
        Book(
            id: UUID(),
            title: "The Da Vinci Code",
            author: ["Dan Brown"],
            genre: "Mystery",
            publicationDate: "2003-03-18",
            totalCopies: 14,
            availableCopies: 8,
            ISBN: "9780307474278",
            Description: "A mystery thriller that follows symbologist Robert Langdon as he investigates a murder in the Louvre.",
            shelfLocation: "Mystery A1",
            dateAdded: "2023-09-05",
            publisher: "Doubleday",
            imageLink: "https://example.com/da-vinci-code.jpg"
        ),
        Book(
            id: UUID(),
            title: "The Alchemist",
            author: ["Paulo Coelho"],
            genre: "Philosophical Fiction",
            publicationDate: "1988-01-01",
            totalCopies: 22,
            availableCopies: 18,
            ISBN: "9780062315007",
            Description: "A philosophical book about a young shepherd named Santiago who dreams of finding a worldly treasure.",
            shelfLocation: "Philosophy A1",
            dateAdded: "2023-10-10",
            publisher: "HarperOne",
            imageLink: "https://example.com/alchemist.jpg"
        )
    ]
    
    
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
        ZStack {
            Color(red: 255/255, green: 239/255, blue: 210/255)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    // Custom TextField with placeholder
                    ZStack(alignment: .leading) {
                        // Actual TextField
                        TextField("", text: $searchText)
                            .padding(.horizontal, 16) // Match placeholder padding
                            .frame(height: 40)
                            .foregroundColor(.black) // Set text color
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
                                .foregroundColor(.gray) // Set placeholder color to gray
                                .padding(.horizontal, 16) // Match TextField padding
                                .font(.custom("sfprodisplaymedium", size: 15))
                                .allowsHitTesting(false) // Allow taps to pass through to TextField
                        }
                    }
                    
                    Button(action: {
                        isSearchPageOpen = false // Dismiss the full-screen view
                    }) {
                        Text("Cancel")
                            .font(.custom("sfprodisplaymedium", size: 15))
                            .foregroundColor(.black)
                    }
                }
                .padding()
                
                // List of filtered books
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(filteredBooks, id: \.id) { book in
                            BookCard(
                                BookImage: book.imageLink, // Use the image URL or name
                                title: book.title,
                                author: book.author.joined(separator: ", "), // Join authors into a single string
                                description: book.Description
                            )
                            .frame(width: 393, height: 80) // Explicitly set the frame
                            .padding(.vertical, 1)
                        }
                    }
                    .frame(maxWidth: .infinity) // Ensure the VStack takes full width
                }
                
                Spacer()
            }
        }
    }
}

#Preview {
    FullScreenSearchView(searchText: .constant(""), isSearchPageOpen: .constant(true))
}
