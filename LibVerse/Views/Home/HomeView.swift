//
//  HomeView.swift
//  LibVerse
//
//  Created by Shahma Ansari on 19/03/25.

import SwiftUI

// MARK: - Model for Popular Books
struct PopularBook: Identifiable {
    let id = UUID()
    let imageName: String
    let title: String
    let author: String
    let rating: Int
    let isBookmarked: Bool
}

// MARK: - Main ContentView with TabView
struct TabBarView: View {
    @State private var selectedTab = 0
    @State private var showMainApp = true
    @State private var showUserInitialView = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(0)
            
            myshelf()
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("MyShelf")
                }
                .tag(1)
            
            UserProfileView(showMainApp: $showMainApp, showUserInitialView: $showUserInitialView)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(2)
            
//            MyShelfView()
//                .tabItem {
//                    Image(systemName: "books.vertical.fill")
//                    Text("MyShelf")
//                }
//                .tag(2)
            
//            MyBookView()
//                .tabItem {
//                    Image(systemName: "book.fill")
//                    Text("MyBook")
//                }
//                .tag(3)
        }
        .tint(Color(red:255/255, green: 111/255, blue: 45/255))
        .onAppear {
            // Set the tab bar background color
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(red: 255/255, green: 239/255, blue: 210/255, alpha: 1.0)
            
            // Use this appearance for both normal and scrolling states
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

// MARK: - HomeView with Announcements and Popular Section
struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding()
                        } else {
                            horizontalBookScroll()
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
                .navigationTitle("Favourites") // Large title here
                .navigationBarTitleDisplayMode(.large) // Makes it large
                .onAppear {
                    viewModel.fetchFavoriteBooks()
                }
                    
                HStack(spacing: 0) {
                    
//                    Rectangle()
//                        .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
//                        .frame(width: 65, height: 65)
//                        .overlay(
//                            Rectangle()
//                                .frame(height: 1.25)
//                                .foregroundColor(.black)
//                                .padding(.top, -1),
//                            alignment: .top
//                        )
//                        .overlay(
//                            Rectangle()
//                                .frame(width: 1.25)
//                                .foregroundColor(.black)
//                                .padding(.trailing, -1),
//                            alignment: .trailing
//                        )
//                        .overlay(
//                            Rectangle()
//                                .frame(height: 1.25)
//                                .foregroundColor(.black)
//                                .padding(.bottom, -1),
//                            alignment: .bottom
//                        )
//
//                    Rectangle()
//                        .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
//                        .frame(maxWidth: .infinity, maxHeight: 65)
//                        .overlay(
//                            Rectangle()
//                                .frame(height: 1.25)
//                                .foregroundColor(.black)
//                                .padding(.top, -1),
//                            alignment: .top
//                        )
//                        .overlay(
//                            Rectangle()
//                                .frame(width: 1.25)
//                                .foregroundColor(.black)
//                                .padding(.leading, -1),
//                            alignment: .leading
//                        )
//                        .overlay(
//                            Rectangle()
//                                .frame(width: 1.25)
//                                .foregroundColor(.black)
//                                .padding(.trailing, -1),
//                            alignment: .trailing
//                        )
//                        .overlay(
//                            Rectangle()
//                                .frame(height: 1.25)
//                                .foregroundColor(.black)
//                                .padding(.bottom, -1),
//                            alignment: .bottom
//                        )
//                        .overlay(
//                            Text("LIBVERSE")
//                                .font(.custom("Charter", size: 23))
//                                .bold()
//                                .foregroundColor(.black)
//                                .padding(.leading, 80),
//                            alignment: .leading
//                        )
//
//                    Rectangle()
//                        .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
//
//                        .frame(width: 65, height: 65)
//                        .overlay(
//                            Rectangle()
//                                .frame(height: 1.25)
//                                .foregroundColor(.black)
//                                .padding(.top, -1),
//                            alignment: .top
//                        )
//                        .overlay(
//                            Rectangle()
//                                .frame(width: 1.25)
//                                .foregroundColor(.black)
//                                .padding(.leading, -1),
//                            alignment: .leading
//                        )
//                        .overlay(
//                            Rectangle()
//                                .frame(height: 1.25)
//                                .foregroundColor(.black)
//                                .padding(.bottom, -1),
//                            alignment: .bottom
//                        )
                       
                        
                }
                .frame(width: 400)
                .padding(.horizontal)
            }
        }

    
    // Helper for section headers
    func sectionHeader(title: String) -> some View {
        HStack {
            Text(title)
                .font(.title2)
                .bold()
            Spacer()
            Button("See All") {}
                .foregroundColor(.orange)
                .font(.system(size: 16, weight: .medium))
        }
        .padding(.horizontal)
    }
    
    // Helper for horizontal scroll of books
    func horizontalBookScroll() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: -35) {
                ForEach(viewModel.popularBooks) { book in
                    PopularCard(book: book)
                }
            }
            .padding(.leading, 11)
        }
    }
}

// MARK: - Popular Book Card with Black Square Border and Increased Width
struct PopularCard: View {
    let book: PopularBook
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Book Cover with Black Square Border
            ZStack {
                Rectangle()
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 120, height: 150)
                
                if book.imageName.isEmpty || book.imageName == "default_book" {
                    Image("mvc")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 115, height: 145)
                        .clipped()
                        .background(Color.white)
                } else {
                    AsyncImage(url: URL(string: book.imageName)) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .frame(width: 115, height: 145)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: 115, height: 145)
                                .clipped()
                        case .failure:
                            Image("mvc")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 115, height: 145)
                                .clipped()
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
            }
            .padding(.bottom, 2)
            
            // Book Title and Author in a VStack with fixed height
            VStack(alignment: .leading, spacing: 2) {
                Text(book.title)
                    .font(.custom("Charter", size: 14))
                    .lineLimit(2)
                    .frame(width: 160, alignment: .leading)
                
                Text(book.author)
                    .font(.custom("Charter", size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .frame(width: 160, alignment: .leading)
            }
            .frame(height: 45) // Fixed height for the text container
        }
        .frame(width: 180)
    }
}

// MARK: - Other Views

struct MyShelfView: View {
    var body: some View {
        Text("MyShelf View")
    }
}

struct MyBookView: View {
    var body: some View {
        Text("MyBook View")
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}

// MARK: - HomeViewModel
class HomeViewModel: ObservableObject {
    @Published var popularBooks: [PopularBook] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let supabaseManager = SupabaseManager.shared
    
    func fetchFavoriteBooks() {
        guard let currentUser = supabaseManager.currentUser else {
            // If no user is logged in, show empty state
            self.popularBooks = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 1. Fetch the current user's favorite book IDs from Member table
                let query = supabaseManager.client
                    .from("Member")
                    .select()
                    .eq("id", value: currentUser.id)
                
                let members: [Member] = try await query.execute().value
                
                guard let member = members.first else {
                    await MainActor.run {
                        self.isLoading = false
                        self.popularBooks = []
                    }
                    return
                }
                
                // 2. If the user has favorites, fetch those books
                if member.favourites.isEmpty {
                    await MainActor.run {
                        self.isLoading = false
                        self.popularBooks = []
                    }
                    return
                }
                
                // Convert array of favorite UUID strings to an array of UUIDs for querying
                let favoriteIds = member.favourites.compactMap { UUID(uuidString: $0) }
                
                // 3. Fetch all favorite books at once using the array of UUIDs
                let bookQuery = supabaseManager.client
                    .from("Books")
                    .select()
                    .in("id", values: favoriteIds)
                
                let books: [Book] = try await bookQuery.execute().value
                
                // 4. Convert books to PopularBook objects
                let favoriteBooks = books.map { book in
                    PopularBook(
                        imageName: book.imageLink ?? "default_book",
                        title: book.title,
                        author: book.author.joined(separator: ", "),
                        rating: Int.random(in: 3...5),
                        isBookmarked: true
                    )
                }
                
                await MainActor.run {
                    self.popularBooks = favoriteBooks
                    self.isLoading = false
                }
            } catch {
                print("Error fetching favorite books: \(error)")
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Failed to load favorite books. Please try again."
                    self.popularBooks = []
                }
            }
        }
    }
}
