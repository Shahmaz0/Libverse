import SwiftUI
import Supabase

// MARK: - Model for Books
struct LibraryBook: Identifiable, Codable {
    let id: UUID
    let title: String
    private let authorArray: [String]?  // To handle author coming as array
    let genre: String?
    let publicationDate: String?
    let totalCopies: Int?
    let availableCopies: Int?
    let ISBN: String?
    let Description: String?
    let shelfLocation: String?
    let dateAdded: String?
    let publisher: String?
    let imageLink: String?
    
    // Computed property to get author string
    var author: String {
        return authorArray?.first ?? "Unknown Author"
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, genre
        case authorArray = "author"  // Map the author array from JSON to authorArray
        case publicationDate = "publicationDate"
        case totalCopies = "totalCopies"
        case availableCopies = "availableCopies"
        case ISBN = "ISBN"
        case Description = "Description"
        case shelfLocation = "shelfLocation"
        case dateAdded = "dateAdded"
        case publisher, imageLink
    }
    
    // Custom initializer to handle potential type mismatches
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode required fields
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        
        // Handle author which could be array or string
        if let authorArr = try? container.decode([String].self, forKey: .authorArray) {
            authorArray = authorArr
        } else if let authorStr = try? container.decode(String.self, forKey: .authorArray) {
            authorArray = [authorStr]
        } else {
            authorArray = nil
        }
        
        // Decode optional fields
        genre = try? container.decode(String.self, forKey: .genre)
        publicationDate = try? container.decode(String.self, forKey: .publicationDate)
        totalCopies = try? container.decode(Int.self, forKey: .totalCopies)
        availableCopies = try? container.decode(Int.self, forKey: .availableCopies)
        ISBN = try? container.decode(String.self, forKey: .ISBN)
        Description = try? container.decode(String.self, forKey: .Description)
        shelfLocation = try? container.decode(String.self, forKey: .shelfLocation)
        dateAdded = try? container.decode(String.self, forKey: .dateAdded)
        publisher = try? container.decode(String.self, forKey: .publisher)
        imageLink = try? container.decode(String.self, forKey: .imageLink)
    }
}

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
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .tag(1)
            
            myshelf()
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("MyShelf")
                }
                .tag(2)
            
            MyBag()
                .tabItem {
                    Image(systemName: "bag.fill")
                    Text("MyBag")
                }
                .tag(3)
            
//            UserProfileView(showMainApp: .constant(true), showUserInitialView: .constant(true))
//                .tabItem {
//                    Image(systemName: "person.crop.circle")
//                    Text("Profile")
//                }
//                .tag(4)
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
    @State private var recentBooks: [LibraryBook] = []
    @State private var isLoadingRecent = true
    @State private var recentError: String?
    
    let popularBooks: [PopularBook] = [
        PopularBook(imageName: "mvc", title: "MVC", author: "R.S. Salaria", rating: 4, isBookmarked: true),
        PopularBook(imageName: "warandpeace", title: "War and Peace", author: "Leo Tolstoy", rating: 5, isBookmarked: false),
        PopularBook(imageName: "harrypotter", title: "Harry Potter", author: "J.K. Rowling", rating: 5, isBookmarked: true)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    sectionHeader(title: "Recent Books")
                    
                    if isLoadingRecent {
                        ProgressView()
                            .scaleEffect(1.2)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if let error = recentError {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else if recentBooks.isEmpty {
                        Text("No recent books available")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        recentBooksScroll()
                    }
                    
                    sectionHeader(title: "Browse By Genre")
                    horizontalBookScroll()
                }
                .padding(.vertical)
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
            .navigationTitle("Madhav")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AnnouncementView()) {
                        Image(systemName: "megaphone.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.system(size: 20))
                            .accessibilityLabel("Announcement")
                    }
                    
                    NavigationLink(destination: 
                        UserProfileView(showMainApp: .constant(true), showUserInitialView: .constant(true))
                            .navigationBarBackButtonHidden(true)
                    ) {
                        Image(systemName: "person.crop.circle")
                            .symbolRenderingMode(.hierarchical)
                            .font(.system(size: 22))
                            .accessibilityLabel("Profile")
                    }
                }
            }
            .onAppear {
                fetchRecentBooks()
            }
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
    
    // Helper for recent books scroll
    func recentBooksScroll() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: -35) {
                ForEach(recentBooks) { book in
                    RecentBookCard(book: book)
                }
            }
            .padding(.leading, 11)
        }
    }
    
    // Helper for horizontal scroll of popular books
    func horizontalBookScroll() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: -35) {
                ForEach(popularBooks) { book in
                    PopularCard(book: book)
                }
            }
            .padding(.leading, 11)
        }
    }
    
    // Function to fetch recent books
    private func fetchRecentBooks() {
        isLoadingRecent = true
        recentError = nil
        
        Task {
            do {
                print("Fetching books from Supabase...")
                let response: [LibraryBook] = try await SupabaseManager.shared.client
                    .from("Books")
                    .select("*")
                    .order("dateAdded", ascending: false)
                    .limit(10)  // Limit to 10 books for better performance
                    .execute()
                    .value
                
                print("Received response from Supabase: \(response)")
                
                DispatchQueue.main.async {
                    self.recentBooks = response
                    self.isLoadingRecent = false
                }
            } catch {
                print("Error fetching books: \(error)")
                DispatchQueue.main.async {
                    self.recentError = "Failed to load recent books: \(error.localizedDescription)"
                    self.isLoadingRecent = false
                }
            }
        }
    }
}

// MARK: - Recent Book Card
struct RecentBookCard: View {
    let book: LibraryBook
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Book Cover with Black Square Border
            ZStack {
                Rectangle()
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 120, height: 150)
                
                if let imageUrl = book.imageLink, !imageUrl.isEmpty {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 115, height: 145)
                    .clipped()
                    .background(Color.white)
                } else {
                    Image(systemName: "book.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60)
                        .foregroundColor(.gray)
                        .frame(width: 115, height: 145)
                        .background(Color.white)
                }
            }
            .padding(.bottom, 2)
            
            // Book Title
            Text(book.title)
                .font(.custom("Charter", size: 14))
                .lineLimit(2)
                .frame(width: 160, alignment: .leading)
            // Author
            Text(book.author)
                .font(.custom("Charter", size: 13))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .frame(width: 180)
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
                
                Image(book.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 115, height: 145)
                    .clipped()
                    .background(Color.white)
            }
            .padding(.bottom, 2)
            
            // Book Title
            Text(book.title)
                .font(.custom("Charter", size: 14))
                .lineLimit(2)
                .frame(width: 160, alignment: .leading)
            // Author
            Text(book.author)
                .font(.custom("Charter", size: 13))
                .foregroundColor(.gray)
                .lineLimit(1)
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
