//
//  myself.swift
//  LibVerse
//
//  Created by Piyush on 21/03/25.
//

import Foundation
import SwiftUI
// The BookDetailView should be available as part of the module, no need for a specific import

// Splash Screen Animation
struct SplashScreen: View {
    @State private var bookRotation: Double = 0
    @State private var bookScale: CGFloat = 1.0
    @State private var bookOpacity: Double = 0.7
    @State private var textOpacity: Double = 0
    @State private var shimmerOffset: CGFloat = -0.25
    @State private var pageFlipAngle: Double = 0
    @State private var currentPage: Int = 0
    
    var body: some View {
        ZStack {
            Color(hex: "FCEFD5")
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                ZStack {
                    // Book shadow
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.black.opacity(0.3))
                        .frame(width: 120, height: 160)
                        .offset(x: 5, y: 5)
                    
                    // Book cover and pages
                    ZStack {
                        // Book base
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color(hex: "DE5B23"))
                            .frame(width: 120, height: 160)
                        
                        // Book spine detail
                        Rectangle()
                            .fill(Color(hex: "C89A69"))
                            .frame(width: 20, height: 160)
                            .offset(x: -50, y: 0)
                        
                        // Book pages
                        ForEach(0..<5) { index in
                            Rectangle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 100, height: 150)
                                .offset(x: 8)
                                .rotationEffect(.degrees(index == currentPage ? pageFlipAngle : 0), anchor: .leading)
                                .opacity(index > currentPage ? 0 : 1)
                        }
                        
                        // Book title lines
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(0..<3) { _ in
                                Rectangle()
                                    .fill(Color.white.opacity(0.7))
                                    .frame(width: 70, height: 8)
                            }
                        }
                        .offset(x: 10)
                        .opacity(pageFlipAngle > 45 ? 0 : 1)
                        
                        // Shimmer effect
                        RoundedRectangle(cornerRadius: 5)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.white.opacity(0.0),
                                        Color.white.opacity(0.5),
                                        Color.white.opacity(0.0)
                                    ]),
                                    startPoint: UnitPoint(x: shimmerOffset, y: 0.5),
                                    endPoint: UnitPoint(x: shimmerOffset + 1, y: 0.5)
                                )
                            )
                            .frame(width: 120, height: 160)
                            .blendMode(.screen)
                    }
                    .rotationEffect(.degrees(bookRotation))
                    .scaleEffect(bookScale)
                    .opacity(bookOpacity)
                }
                
                Text("Pustakalaya")
                    .font(.custom("Charter", size: 32))
                    .foregroundColor(Color(hex: "7C4B2D"))
                    .opacity(textOpacity)
                
                Text("Loading your shelves...")
                    .font(.custom("Charter", size: 16))
                    .foregroundColor(Color(hex: "7C4B2D"))
                    .opacity(textOpacity)
            }
        }
        .onAppear {
            // Rotating animation
            withAnimation(Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                bookRotation = 10
                bookScale = 1.1
                bookOpacity = 1.0
            }
            
            // Text fade in
            withAnimation(Animation.easeIn(duration: 0.7).delay(0.3)) {
                textOpacity = 1.0
            }
            
            // Shimmer animation
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 1.25
            }
            
            // Page flip animation
            flipPages()
        }
    }
    
    private func flipPages() {
        // Initial delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            flipPage()
        }
    }
    
    private func flipPage() {
        withAnimation(Animation.easeInOut(duration: 0.6)) {
            pageFlipAngle = 180
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            // Reset angle without animation and set up next page
            pageFlipAngle = 0
            currentPage = (currentPage + 1) % 5
            
            // Recursively call flipPage for continuous animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                flipPage()
            }
        }
    }
}

// Shimmer Book Cover View
struct ShimmerBookCover: View {
    @State private var shimmerOffset: CGFloat = -0.25
    var opacity: Double = 1.0
    
    var body: some View {
        ZStack {
            // Book base shape
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3 * opacity))
                .frame(width: 93, height: 120)
            
            // Book spine
            HStack(spacing: 0) {
                // Spine
                Rectangle()
                    .fill(Color.gray.opacity(0.5 * opacity))
                    .frame(width: 10, height: 120)
                
                Spacer()
            }
            .frame(width: 93)
            
            // Title lines
            VStack(alignment: .leading, spacing: 8) {
                ForEach(0..<3) { _ in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.gray.opacity(0.4 * opacity))
                        .frame(width: 60, height: 6)
                }
                
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.gray.opacity(0.4 * opacity))
                    .frame(width: 40, height: 6)
            }
            .padding(.leading, 20)
            
            // Shimmer effect
            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.gray.opacity(0.2 * opacity),
                            Color.white.opacity(0.5 * opacity),
                            Color.gray.opacity(0.2 * opacity)
                        ]),
                        startPoint: UnitPoint(x: shimmerOffset, y: 0.5),
                        endPoint: UnitPoint(x: shimmerOffset + 1, y: 0.5)
                    )
                )
                .frame(width: 93, height: 120)
        }
        .onAppear {
            withAnimation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                shimmerOffset = 1.25
            }
        }
    }
}

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
    @State private var isLoading: Bool = false
    @State private var isInitialLoading: Bool = true  // Track if this is the initial tab load
    @State private var errorMessage: String? = nil
    @EnvironmentObject var supabaseManager: SupabaseManager
    
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
        NavigationView {
            ZStack {
                Color(hex: "FCEFD5")
                    .ignoresSafeArea()
                
                if isLoading && isInitialLoading {
                    SplashScreen()
                        .transition(.opacity)
                } else {
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
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
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
                                                                NavigationLink(destination: BookDetailView(book: selectedBooks[bookIndex])) {
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
                                                                            ZStack {
                                                                                ShimmerBookCover(opacity: 0.8)
                                                                                
                                                                                // Add a small error indicator
                                                                                Image(systemName: "exclamationmark.triangle.fill")
                                                                                    .font(.system(size: 20))
                                                                                    .foregroundColor(Color(hex: "DE5B23").opacity(0.8))
                                                                                    .offset(y: -40)
                                                                            }
                                                                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                                                                        case .empty:
                                                                            ShimmerBookCover(opacity: 0.8)
                                                                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                                                                        @unknown default:
                                                                            EmptyView()
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                        }
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
            }
            .animation(.easeInOut(duration: 0.5), value: isLoading)
            .sheet(isPresented: $showingAddModal) {
                AddModalView { newShelfName in
                    createNewShelf(newShelfName)
                }
            }
            .sheet(isPresented: $showingTodoModal) {
                AddBooksToShelf(shelfBooks: $shelfBooks, selectedCategory: selectedCategory) { book in
                    addBookToCurrentShelf(book)
                }
            }
            .alert("Delete Book", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {
                    bookToDelete = nil
                }
                Button("Delete", role: .destructive) {
                    if let index = bookToDelete {
                        removeBookFromShelf(at: index)
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
                        deleteShelf(name: shelf)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this shelf? All books in this shelf will be removed.")
            }
            .onAppear {
                loadUserShelves()
            }
            .navigationBarHidden(true)
        }
    }
    
    private func loadUserShelves() {
        guard let currentUser = supabaseManager.currentUser else {
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let userShelves = try await supabaseManager.fetchUserShelves(userId: currentUser.id)
                
                var loadedCategories = ["Favorites"]
                var loadedShelfBooks: [String: [Book]] = [:]
                
                for (shelfName, bookIds) in userShelves {
                    if !loadedCategories.contains(shelfName) {
                        loadedCategories.append(shelfName)
                    }
                    
                    if !bookIds.isEmpty {
                        let uuidValues = bookIds.compactMap { UUID(uuidString: $0) }
                        
                        if !uuidValues.isEmpty {
                            let books: [Book] = try await supabaseManager.client
                                .from("Books")
                                .select()
                                .in("id", values: uuidValues)
                                .execute()
                                .value
                            
                            loadedShelfBooks[shelfName] = books
                        } else {
                            loadedShelfBooks[shelfName] = []
                        }
                    } else {
                        loadedShelfBooks[shelfName] = []
                    }
                }
                
                await MainActor.run {
                    categories = loadedCategories
                    shelfBooks = loadedShelfBooks
                    isLoading = false
                    isInitialLoading = false // Set to false after first successful load
                    
                    if !loadedCategories.contains(selectedCategory) {
                        selectedCategory = "Favorites"
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to load shelves: \(error.localizedDescription)"
                    isLoading = false
                    isInitialLoading = false // Still set to false even if there's an error
                }
            }
        }
    }
    
    private func createNewShelf(_ shelfName: String) {
        guard let currentUser = supabaseManager.currentUser else {
            return
        }
        
        Task {
            do {
                try await supabaseManager.createShelf(userId: currentUser.id, shelfName: shelfName)
                
                await MainActor.run {
                    categories.append(shelfName)
                    shelfBooks[shelfName] = []
                    selectedCategory = shelfName
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        refreshShelves()
                    }
                }
            } catch {
                // Error handling without debug prints
            }
        }
    }
    
    private func deleteShelf(name: String) {
        guard let currentUser = supabaseManager.currentUser else {
            return
        }
        
        Task {
            do {
                try await supabaseManager.deleteShelf(userId: currentUser.id, shelfName: name)
                
                await MainActor.run {
                    categories.removeAll { $0 == name }
                    shelfBooks.removeValue(forKey: name)
                    
                    if selectedCategory == name {
                        selectedCategory = "Favorites"
                    }
                }
            } catch {
                // Error handling without debug prints
            }
        }
    }
    
    private func addBookToCurrentShelf(_ book: Book) {
        guard let currentUser = supabaseManager.currentUser else {
            return
        }
        
        Task {
            do {
                try await supabaseManager.addBookToShelf(
                    userId: currentUser.id,
                    shelfName: selectedCategory,
                    bookId: book.id
                )
                
                await MainActor.run {
                    var currentBooks = shelfBooks[selectedCategory] ?? []
                    currentBooks.append(book)
                    shelfBooks[selectedCategory] = currentBooks
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        refreshShelves()
                    }
                }
            } catch {
                // Error handling without debug prints
            }
        }
    }
    
    private func removeBookFromShelf(at index: Int) {
        guard let currentUser = supabaseManager.currentUser,
              index < selectedBooks.count else {
            return
        }
        
        let book = selectedBooks[index]
        
        Task {
            do {
                try await supabaseManager.removeBookFromShelf(
                    userId: currentUser.id,
                    shelfName: selectedCategory,
                    bookId: book.id
                )
                
                await MainActor.run {
                    var currentBooks = shelfBooks[selectedCategory] ?? []
                    currentBooks.remove(at: index)
                    shelfBooks[selectedCategory] = currentBooks
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        refreshShelves()
                    }
                }
            } catch {
                // Error handling without debug prints
            }
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
    
    private func refreshShelves() {
        guard let currentUser = supabaseManager.currentUser else {
            return
        }
        
        // Don't set isLoading to true to avoid showing loading indicators
        
        Task {
            do {
                let userShelves = try await supabaseManager.fetchUserShelves(userId: currentUser.id)
                
                var loadedCategories = ["Favorites"]
                var loadedShelfBooks: [String: [Book]] = [:]
                
                for (shelfName, bookIds) in userShelves {
                    if !loadedCategories.contains(shelfName) {
                        loadedCategories.append(shelfName)
                    }
                    
                    if !bookIds.isEmpty {
                        let uuidValues = bookIds.compactMap { UUID(uuidString: $0) }
                        
                        if !uuidValues.isEmpty {
                            let books: [Book] = try await supabaseManager.client
                                .from("Books")
                                .select()
                                .in("id", values: uuidValues)
                                .execute()
                                .value
                            
                            loadedShelfBooks[shelfName] = books
                        } else {
                            loadedShelfBooks[shelfName] = []
                        }
                    } else {
                        loadedShelfBooks[shelfName] = []
                    }
                }
                
                await MainActor.run {
                    categories = loadedCategories
                    shelfBooks = loadedShelfBooks
                    
                    if !loadedCategories.contains(selectedCategory) {
                        selectedCategory = "Favorites"
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to refresh shelves: \(error.localizedDescription)"
                }
            }
        }
    }
}

struct AddBooksToShelf: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText: String = ""
    @StateObject private var dataController = DataController()
    @Binding var shelfBooks: [String: [Book]]
    let selectedCategory: String
    var onBookSelected: (Book) -> Void
    
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
                                onBookSelected(book)
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
        .environmentObject(SupabaseManager.shared)
} 
