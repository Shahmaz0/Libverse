//
//  myself.swift
//  LibVerse
//
//  Created by Piyush on 21/03/25.
//

import Foundation
import SwiftUI
import CommonCrypto



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
                                RefreshableScrollView(action: {
                                    await refreshShelves()
                                }) {
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
                                                                        CachedImage(url: imageUrl)
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
                // To make sure we load cached images on app startup
                _ = ImageCache.shared
                
                // Add observer for when member data is loaded (handles app restart scenarios)
                NotificationCenter.default.addObserver(forName: NSNotification.Name("MemberDataLoaded"), object: nil, queue: .main) { _ in
                    loadUserShelves()
                }
            }
            .onDisappear {
                // Save cached URLs when view disappears
                ImageCache.shared.saveURLsToUserDefaults()
                
                // Remove notification observer
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name("MemberDataLoaded"), object: nil)
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
                
                await withTaskGroup(of: (String, [Book]).self) { group in
                    for (shelfName, bookIds) in userShelves {
                        if !loadedCategories.contains(shelfName) {
                            loadedCategories.append(shelfName)
                        }
                        
                        group.addTask {
                            if !bookIds.isEmpty {
                                let uuidValues = bookIds.compactMap { UUID(uuidString: $0) }
                                
                                if !uuidValues.isEmpty {
                                    do {
                                        let books: [Book] = try await supabaseManager.client
                                            .from("Books")
                                            .select()
                                            .in("id", values: uuidValues)
                                            .execute()
                                            .value
                                        
                                        return (shelfName, books)
                                    } catch {
                                        return (shelfName, [])
                                    }
                                }
                            }
                            return (shelfName, [])
                        }
                    }
                    
                    for await (shelfName, books) in group {
                        loadedShelfBooks[shelfName] = books
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
                    
                    Task {
                        await refreshShelves()
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
                    
                    Task {
                        await refreshShelves()
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
                    
                    Task {
                        await refreshShelves()
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
    
    private func refreshShelves() async {
        guard let currentUser = supabaseManager.currentUser else {
            return
        }
        
        do {
            let userShelves = try await supabaseManager.fetchUserShelves(userId: currentUser.id)
            
            var loadedCategories = ["Favorites"]
            var loadedShelfBooks: [String: [Book]] = [:]
            
            await withTaskGroup(of: (String, [Book]).self) { group in
                for (shelfName, bookIds) in userShelves {
                    if !loadedCategories.contains(shelfName) {
                        loadedCategories.append(shelfName)
                    }
                    
                    group.addTask {
                        if !bookIds.isEmpty {
                            let uuidValues = bookIds.compactMap { UUID(uuidString: $0) }
                            
                            if !uuidValues.isEmpty {
                                do {
                                    let books: [Book] = try await supabaseManager.client
                                        .from("Books")
                                        .select()
                                        .in("id", values: uuidValues)
                                        .execute()
                                        .value
                                    
                                    return (shelfName, books)
                                } catch {
                                    return (shelfName, [])
                                }
                            }
                        }
                        return (shelfName, [])
                    }
                }
                
                for await (shelfName, books) in group {
                    loadedShelfBooks[shelfName] = books
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
