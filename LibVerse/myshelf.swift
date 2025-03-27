//
//  myself.swift
//  LibVerse
//
//  Created by Piyush on 21/03/25.
//

import Foundation
import SwiftUI

// Modal View
struct AddModalView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selfName: String = ""
    var onCreateShelf: (String) -> Void
    
    var body: some View {
        ZStack {
            Color(hex: "FCEFD5")
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Give your shelf a name")
                    .font(.custom("Charter", size: 32))
                    .foregroundColor(Color(hex: "7C4B2D"))
                    .padding(.top, 40)
            
                TextField("Hello World", text: $selfName)
                    .textFieldStyle(PlainTextFieldStyle())
                 
                    .padding()
                    .frame(width: UIScreen.main.bounds.width - 80, height: 50)
                    .background(Color(hex: "FCEFD5"))
                    .overlay(
                        RoundedRectangle(cornerRadius: 0)
                            .stroke(Color.black, lineWidth: 1)
                    )
                
                // Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .font(.custom("Charter", size: 20))
                            .foregroundColor(.black)
                            .frame(width: 150, height: 50)
                            .background(Color(hex: "FCEFD5"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }

                    Button(action: {
                        if !selfName.isEmpty {
                            onCreateShelf(selfName)
                            dismiss()
                        }
                    }) {
                        Text("Create")
                            .font(.custom("Charter", size: 20))
                            .foregroundColor(.white)
                            .frame(width: 150, height: 50)
                            .background(Color(hex: "DE5B23"))
                    }
                }
                .padding(.top, 20)
                
                Spacer()
            }
            .padding()
        }
    }
}



struct myshelf: View {
    @State private var showingAddModal = false
    @State private var showingTodoModal = false
    @State private var categories: [String] = ["Favorites"]
    @State private var selectedCategory: String = "Favorites"
    @State private var shelfBooks: [String: [Book]] = [:]  // Dictionary to store books for each shelf
    @State private var showingDeleteAlert = false
    @State private var bookToDelete: Int? = nil
    @State private var showingDeleteShelfAlert = false
    @State private var shelfToDelete: String? = nil
    @State private var draggedBook: Int? = nil
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    
    var selectedBooks: [Book] {
        let books = shelfBooks[selectedCategory] ?? []
        if searchText.isEmpty {
            return books
        } else {
            return books.filter { book in
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
            
            VStack(spacing: 0) {
                // Header
                Rectangle()
                    .fill(Color(hex: "FCEFD5"))
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
                            .frame(height: 1.25)
                            .foregroundColor(.black)
                            .padding(.bottom, -1),
                        alignment: .bottom
                    )
                    .overlay(
                        HStack {
                            Text("My Shelf")
                                .font(.custom("Charter", size: 20))
                                .bold()
                                .foregroundColor(.black)
                                .padding(.leading, 20)
                            
                            Spacer()
                            
                            // Search button
                            Button(action: {
                                isSearching = true
                            }) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(Color.black)
                            }
                            .padding(.trailing, 15)
                            
                            // Add button
                            Button(action: {
                                showingAddModal = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.system(size: 28, weight: .medium))
                                    .foregroundColor(Color.black)
                            }
                            .padding(.trailing, 20)
                        }
                    )
                
                // Search bar (when searching)
                if isSearching {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Color(hex: "875232"))
                            .padding(.leading, 10)
                        
                        TextField("Search books...", text: $searchText)
                            .font(.custom("Charter", size: 16))
                            .padding(.vertical, 12)
                        
                        Button(action: {
                            isSearching = false
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(Color(hex: "875232"))
                        }
                        .padding(.trailing, 10)
                    }
                    .background(Color(hex: "FCEFD5"))
                    .overlay(
                        Rectangle()
                            .stroke(Color.black, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .padding(.top, 20)
                } else {
                    
                    // Category buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(categories, id: \.self) { category in
                                Button(action: {
                                    selectedCategory = category
                                }) {
                                    Text(category)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(category == selectedCategory ? .white : Color.black)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            category == selectedCategory ?
                                            Color(hex: "DE5B23") :
                                            Color(hex: "FCEFD5")
                                        )
                                        .border(.black)
                                }
                                .simultaneousGesture(
                                    LongPressGesture(minimumDuration: 0.5)
                                        .onEnded { _ in
                                            if category != "Favorites" {
                                                shelfToDelete = category
                                                showingDeleteShelfAlert = true
                                            }
                                        }
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                }
                
                // Fixed top thick line
                Rectangle()
                    .fill(Color(hex: "C89A69"))
                    .frame(width: UIScreen.main.bounds.width, height: 28)
                    .padding(.top, 20)
                
                // Add continuous vertical lines that span the entire scroll area
                ZStack {
                    // Left vertical line
                    Rectangle()
                        .fill(Color(hex: "C89A69"))
                        .frame(width: 12)
                        .frame(maxHeight: .infinity)
                        .position(x: 6, y: UIScreen.main.bounds.height/2.8)
                        .edgesIgnoringSafeArea(.bottom)
                    
                    // Right vertical line
                    Rectangle()
                        .fill(Color(hex: "C89A69"))
                        .frame(width: 12)
                        .frame(maxHeight: .infinity)
                        .position(x: UIScreen.main.bounds.width - 6, y: UIScreen.main.bounds.height/2.8)
                        .edgesIgnoringSafeArea(.bottom)
                    
                    // Scrollable content
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(0..<20) { index in
                                // Image section
                                ZStack {
                                    Image("selfbackgroun")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: UIScreen.main.bounds.width - 24, height: 143)
                                        .clipped()
                                    
                                    HStack(spacing: 14) {
                                        ForEach(0..<3) { rectangleIndex in
                                            let bookIndex = (index * 3) + rectangleIndex
                                            if shouldShowPlusButton(at: bookIndex) {
                                                Button(action: {
                                                    showingTodoModal = true
                                                }) {
                                                    ZStack {
                                                        Rectangle()
                                                            .fill(Color.white)
                                                            .frame(width: 93, height: 120)
                                                            .shadow(color: .black.opacity(0.8), radius:15, x: 0, y: 13)
                                                        
                                                        Image(systemName: "plus")
                                                            .font(.system(size: 30))
                                                            .foregroundColor(Color(hex: "875232"))
                                                    }
                                                }
                                            } else if bookIndex < selectedBooks.count {
                                                ZStack {
                                                    Rectangle()
                                                        .fill(Color.clear)
                                                        .frame(width: 93, height: 120)
                                                        .shadow(color: .black.opacity(0.8), radius: 15, x: 0, y: 13)
                                                    
                                                    if let imageUrl = selectedBooks[bookIndex].imageLink {
                                                        AsyncImage(url: URL(string: imageUrl)) { phase in
                                                            switch phase {
                                                            case .success(let image):
                                                                image
                                                                    .resizable()
                                                                    .scaledToFill()
                                                                    .frame(width: 93, height: 120)
                                                                    .clipped()
                                                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                                                            case .failure:
                                                                Image("mvc")
                                                                    .resizable()
                                                                    .scaledToFill()
                                                                    .frame(width: 93, height: 120)
                                                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                                                            case .empty:
                                                                ProgressView()
                                                            @unknown default:
                                                                EmptyView()
                                                            }
                                                        }
                                                    }
                                                }
                                                //drag and drop functionality to change the book position.(remove it if the code become to large)
//                                                .offset(y: draggedBook == bookIndex ? -10 : 0)
//                                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: draggedBook)
//                                                .gesture(
//                                                    DragGesture(minimumDistance: 0)
//                                                        .onChanged { gesture in
//                                                            if draggedBook == nil {
//                                                                draggedBook = bookIndex
//                                                            }
//                                                        }
//                                                        .onEnded { gesture in
//                                                            if let draggedIndex = draggedBook {
//                                                                let translation = gesture.translation
//                                                                let newIndex = calculateNewIndex(
//                                                                    currentIndex: draggedIndex,
//                                                                    translation: translation,
//                                                                    totalBooks: selectedBooks.count
//                                                                )
//                                                                
//                                                                if newIndex != draggedIndex {
//                                                                    var updatedBooks = selectedBooks
//                                                                    let book = updatedBooks.remove(at: draggedIndex)
//                                                                    updatedBooks.insert(book, at: newIndex)
//                                                                    shelfBooks[selectedCategory] = updatedBooks
//                                                                }
//                                                            }
//                                                            draggedBook = nil
//                                                        }
//                                                )
                                                .simultaneousGesture(
                                                    LongPressGesture(minimumDuration: 0.5)
                                                        .onEnded { _ in
                                                            bookToDelete = bookIndex
                                                            showingDeleteAlert = true
                                                        }
                                                )
                                            } else {
                                                ZStack {
                                                    Rectangle()
                                                        .fill(Color.clear)
                                                        .frame(width: 93, height: 120)
                                                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                                                    
                                                    Text("\(bookIndex + 1)")
                                                        .font(.system(size: 24, weight: .bold))
                                                        .foregroundColor(Color.clear)
                                                }
                                            }
                                        }
                                    }
                                    .offset(y: 10)
                                }
                                
                                // Horizontal line
                                Rectangle()
                                    .fill(Color(hex: "C89A69"))
                                    .frame(width: UIScreen.main.bounds.width - 24, height: 12)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddModal) {
            AddModalView { newShelfName in
                categories.append(newShelfName)
                selectedCategory = newShelfName
            }
        }
        .sheet(isPresented: $showingTodoModal) {
            AddBooksToShelf(shelfBooks: $shelfBooks, selectedCategory: selectedCategory)
        }
        .alert("Delete Book", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) {
                bookToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let index = bookToDelete {
                    var currentBooks = shelfBooks[selectedCategory] ?? []
                    currentBooks.remove(at: index)
                    shelfBooks[selectedCategory] = currentBooks
                }
            }
        } message: {
            Text("Are you sure you want to delete this book from your shelf?")
        }
        .alert("Delete Shelf", isPresented: $showingDeleteShelfAlert) {
            Button("Cancel", role: .cancel) {
                shelfToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let shelf = shelfToDelete {
                    // Remove the shelf from categories
                    categories.removeAll { $0 == shelf }
                    // Remove the shelf's books
                    shelfBooks.removeValue(forKey: shelf)
                    // If the deleted shelf was selected, switch to Favorites
                    if selectedCategory == shelf {
                        selectedCategory = "Favorites"
                    }
                }
            }
        } message: {
            Text("Are you sure you want to delete this shelf? All books in this shelf will be removed.")
        }
    }
    
    private func calculateNewIndex(currentIndex: Int, translation: CGSize, totalBooks: Int) -> Int {
        let rowWidth: CGFloat = 93 + 14 // book width + spacing
        let rowHeight: CGFloat = 143 + 12 // row height + spacing
        
        let horizontalMove = Int(translation.width / rowWidth)
        let verticalMove = Int(translation.height / rowHeight)
        
        let booksPerRow = 3
        let newIndex = currentIndex + (verticalMove * booksPerRow) + horizontalMove
        
        return max(0, min(newIndex, totalBooks - 1))
    }
    
    private func shouldShowPlusButton(at index: Int) -> Bool {
        return index == selectedBooks.count
    }
}

struct AddBooksToShelf: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    @StateObject private var dataController = DataController()
    @Binding var shelfBooks: [String: [Book]]
    let selectedCategory: String
    
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
                            Button(action: {
                                var currentBooks = shelfBooks[selectedCategory] ?? []
                                currentBooks.append(book)
                                shelfBooks[selectedCategory] = currentBooks
                                dismiss()
                            }) {
                                BookCard(
                                    BookImage: book.imageLink ?? "mvc",
                                    title: book.title,
                                    author: book.author.joined(separator: ", "),
                                    description: book.Description ?? "No description available",
                                    showPlusButton: true
                                )
                            }
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
        }
    }
}

// Extension to support hex color
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    myshelf()
} 
