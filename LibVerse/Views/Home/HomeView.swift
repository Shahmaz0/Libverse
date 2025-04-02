import SwiftUI
import Supabase

// MARK: - Color Extension


// MARK: - NotificationBadge Component
struct NotificationBadge: View {
    let count: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.red)
                .frame(width: 18, height: 18)
            
            Text("\(min(count, 99))")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - HomeView with Announcements and Popular Section
struct HomeView: View {
    @State private var recentBooks: [LibraryBook] = []
    @State private var recommendedBooks: [LibraryBook] = []
    @State private var genreBooks: [LibraryBook] = []
    @State private var isLoadingRecent = true
    @State private var isLoadingRecommended = true
    @State private var isLoadingGenre = true
    @State private var recentError: String?
    @State private var recommendedError: String?
    @State private var genreError: String?
    @State private var selectedGenre: String?
    @State private var showGenreOnboarding = false
    @ObservedObject private var announcementManager = AnnouncementManager.shared
    
    // Updated genres based on the database
    let genres = ["Technology", "Business", "Reference", "Medicine", "Mathematics", "Law", "Science"]
    
    let popularBooks: [PopularBook] = [
        PopularBook(imageName: "mvc", title: "MVC", author: "R.S. Salaria", rating: 4, isBookmarked: true),
        PopularBook(imageName: "warandpeace", title: "War and Peace", author: "Leo Tolstoy", rating: 5, isBookmarked: false),
        PopularBook(imageName: "harrypotter", title: "Harry Potter", author: "J.K. Rowling", rating: 5, isBookmarked: true)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // More to Explore Section
                    Text("More to Explore")
                        .font(.title2)
                        .bold()
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                                
                            //Rectangle 1 (Fiction & Literature)
                            NavigationLink(destination: FictionLiteratureView()) {
                                ZStack {
                                    Rectangle()
                                        .fill(Color(hex: "C89A69"))
                                        .frame(width: 370, height: 200)
                                        .overlay(
                                            Rectangle()
                                                .stroke(Color.black, lineWidth:2)
                                        )
                                    
                                    Image("F&LCard")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 356, height: 198)
                                        .clipped()
                                }
                            }
                            
                            //Rectangle 2 (Non-Fiction)
                            NavigationLink(destination: NonFictionView()) {
                                ZStack {
                                    Rectangle()
                                        .fill(Color(hex: "C89A69"))
                                        .frame(width: 370, height: 200)
                                        .overlay(
                                            Rectangle()
                                                .stroke(Color.black, lineWidth: 2)
                                        )
                                    
                                    Image("Non-fiction")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 356, height: 198)
                                        .clipped()
                                }
                            }
                            
                            
                        }
                        .padding(.horizontal, 18)
                    }

                    sectionHeader(title: "Latest Arrivals")
                    
                    if isLoadingRecent {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: -35) {
                                ForEach(0..<5, id: \.self) { _ in
                                    BookCardSkeleton()
                                }
                            }
                            .padding(.leading, 11)
                        }
                    } else if let error = recentError {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else if recentBooks.isEmpty {
                        Text("No new arrivals available")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        recentBooksScroll()
                    }
                    
                    sectionHeader(title: "For You")
                    
                    if isLoadingRecommended {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: -35) {
                                ForEach(0..<5, id: \.self) { _ in
                                    BookCardSkeleton()
                                }
                            }
                            .padding(.leading, 11)
                        }
                    } else if let error = recommendedError {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else if recommendedBooks.isEmpty {
                        Text("No personalized recommendations available")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        recommendedBooksScroll()
                    }
                    
                    sectionHeader(title: "Browse By Genre")
                    
                    // Genre Selection ScrollView
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(genres, id: \.self) { genre in
                                GenreButton(
                                    genre: genre,
                                    isSelected: selectedGenre == genre,
                                    action: {
                                        selectedGenre = genre
                                        fetchBooksByGenre(genre)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    // Genre Books Display
                    if isLoadingGenre {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: -35) {
                                ForEach(0..<5, id: \.self) { _ in
                                    BookCardSkeleton()
                                }
                            }
                            .padding(.leading, 11)
                        }
                    } else if let error = genreError {
                        Text(error)
                            .foregroundColor(.red)
                            .padding()
                    } else if !genreBooks.isEmpty {
                        genreBooksScroll()
                    }
                }
                .padding(.vertical)
            }
            .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
            .navigationTitle("Madhav")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AnnouncementView()) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "megaphone.fill")
                                .symbolRenderingMode(.hierarchical)
                                .font(.system(size: 20))
                                .accessibilityLabel("Announcement")
                            
                            if announcementManager.unreadCount > 0 {
                                NotificationBadge(count: announcementManager.unreadCount)
                                    .offset(x: 8, y: -8)
                            }
                        }
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
                checkOnboardingStatus()
                fetchRecentBooks()
                fetchRecommendedBooks()
                
                // Make sure member data is loaded before fetching announcements
                Task {
                    if SupabaseManager.shared.currentMember == nil && SupabaseManager.shared.currentUser != nil {
                        await SupabaseManager.shared.fetchCurrentMember()
                    }
                    
                    // Fetch announcements after ensuring member data is loaded
                    announcementManager.fetchAnnouncements()
                }
            }
            .sheet(isPresented: $showGenreOnboarding) {
                GenreSelectionView(showOnboarding: $showGenreOnboarding)
                    .onDisappear {
                        // Refresh recommendations when sheet is dismissed
                        fetchRecommendedBooks()
                    }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("genrePreferencesUpdated"))) { _ in
                // Refresh recommendations when genre preferences are updated
                fetchRecommendedBooks()
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
            if title == "Latest Arrivals" {
                NavigationLink(destination: AllBooksView(title: title, books: recentBooks, isLoading: isLoadingRecent)) {
                    Text("See All")
                        .foregroundColor(.orange)
                        .font(.system(size: 16, weight: .medium))
                }
            } else if title == "For You" {
                NavigationLink(destination: AllBooksView(title: title, books: recommendedBooks, isLoading: isLoadingRecommended)) {
                    Text("See All")
                        .foregroundColor(.orange)
                        .font(.system(size: 16, weight: .medium))
                }
            } else if title == "Browse By Genre" && selectedGenre != nil {
                NavigationLink(destination: AllBooksView(title: selectedGenre ?? "Genre", books: genreBooks, isLoading: isLoadingGenre)) {
                    Text("See All")
                        .foregroundColor(.orange)
                        .font(.system(size: 16, weight: .medium))
                }
            } else {
                Button("See All") {}
                    .foregroundColor(.orange)
                    .font(.system(size: 16, weight: .medium))
            }
        }
        .padding(.horizontal)
    }
    
    // Helper for recent books scroll
    func recentBooksScroll() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: -35) {
                ForEach(recentBooks) { book in
                    NavigationLink(destination: BookDetailView(book: Book(from: book))) {
                        RecentBookCard(book: book)
                    }
                }
            }
            .padding(.leading, 11)
        }
    }
    
    // Helper for recommended books scroll
    func recommendedBooksScroll() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: -35) {
                ForEach(recommendedBooks) { book in
                    NavigationLink(destination: BookDetailView(book: Book(from: book))) {
                        RecentBookCard(book: book)
                    }
                }
            }
            .padding(.leading, 11)
        }
    }
    
    // Helper for genre books scroll
    func genreBooksScroll() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: -35) {
                ForEach(genreBooks) { book in
                    NavigationLink(destination: BookDetailView(book: Book(from: book))) {
                        RecentBookCard(book: book)
                    }
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
                print("Fetching recent books from Supabase...")
                let response: [LibraryBook] = try await SupabaseManager.shared.client
                    .from("Books")
                    .select("*")
                    .order("dateAdded", ascending: false)
                    .limit(10)
                    .execute()
                    .value
                
                print("Received response from Supabase: \(response)")
                
                DispatchQueue.main.async {
                    self.recentBooks = response
                    self.isLoadingRecent = false
                }
            } catch {
                print("Error fetching recent books: \(error)")
                DispatchQueue.main.async {
                    self.recentError = "Failed to load recent books: \(error.localizedDescription)"
                    self.isLoadingRecent = false
                }
            }
        }
    }
    
    // Function to fetch recommended books based on user preferences
    private func fetchRecommendedBooks() {
        isLoadingRecommended = true
        recommendedError = nil
        
        Task {
            do {
                print("Fetching recommended books from Supabase...")
                
                // Get user genre preferences
                let userGenres = UserPreferences.shared.getGenrePreferences()
                
                // If user has genre preferences, filter by those genres
                var query = SupabaseManager.shared.client
                    .from("Books")
                    .select("*")
                
                if !userGenres.isEmpty {
                    // Filter by user's genre preferences
                    query = query.in("genre", values: userGenres)
                }
                
                let response: [LibraryBook] = try await query
                    .order("dateAdded", ascending: false)
                    .limit(10)
                    .execute()
                    .value
                
                print("Received recommended books from Supabase: \(response)")
                
                DispatchQueue.main.async {
                    self.recommendedBooks = response
                    self.isLoadingRecommended = false
                }
            } catch {
                print("Error fetching recommended books: \(error)")
                DispatchQueue.main.async {
                    self.recommendedError = "Failed to load recommended books: \(error.localizedDescription)"
                    self.isLoadingRecommended = false
                }
            }
        }
    }
    
    // Function to fetch books by genre
    private func fetchBooksByGenre(_ genre: String) {
        isLoadingGenre = true
        genreError = nil
        genreBooks = [] // Clear previous books
        
        Task {
            do {
                print("Fetching books for genre: \(genre)")
                let response: [LibraryBook] = try await SupabaseManager.shared.client
                    .from("Books")
                    .select("*")
                    .eq("genre", value: genre)
                    .order("dateAdded", ascending: false)
                    .limit(10)
                    .execute()
                    .value
                
                print("Received books for genre \(genre): \(response)")
                
                DispatchQueue.main.async {
                    self.genreBooks = response
                    self.isLoadingGenre = false
                    
                    // If no books found, deselect the genre
                    if response.isEmpty {
                        self.selectedGenre = nil
                    }
                }
            } catch {
                print("Error fetching books for genre \(genre): \(error)")
                DispatchQueue.main.async {
                    self.genreError = "Failed to load books: \(error.localizedDescription)"
                    self.isLoadingGenre = false
                    self.selectedGenre = nil // Reset selection on error
                }
            }
        }
    }
    
    // Check if user has completed genre onboarding
    private func checkOnboardingStatus() {
        if !UserPreferences.shared.hasCompletedGenreOnboarding() {
            showGenreOnboarding = true
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
            
            // Text Container
            VStack(alignment: .leading, spacing: 2) {
                Text(book.title)
                    .font(.custom("Charter", size: 14))
                    .lineLimit(2)
                    .frame(width: 160, alignment: .leading)
                    .multilineTextAlignment(.leading)
                
                Text(book.author)
                    .font(.custom("Charter", size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .frame(width: 160, alignment: .leading)
            }
            .frame(width: 160)
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
            
            // Text Container
            VStack(alignment: .leading, spacing: 2) {
                Text(book.title)
                    .font(.custom("Charter", size: 14))
                    .lineLimit(2)
                    .frame(width: 160, alignment: .leading)
                    .multilineTextAlignment(.leading)
                
                Text(book.author)
                    .font(.custom("Charter", size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .frame(width: 160, alignment: .leading)
            }
            .frame(width: 160)
        }
        .frame(width: 180)
    }
}

// MARK: - Genre Button
struct GenreButton: View {
    let genre: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(genre)
                .font(.system(size: 14, weight: .medium))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? Color.orange : Color.white)
                .foregroundColor(isSelected ? .white : .black)
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? Color.orange : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

// MARK: - BookCardSkeleton Component
struct BookCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Skeleton for book cover
            ZStack {
                Rectangle()
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 120, height: 150)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 115, height: 145)
                    .shimmering()
            }
            
            // Skeleton for title
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 14)
                .cornerRadius(2)
                .shimmering()
                .padding(.top, 4)
            
            // Skeleton for author
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 13)
                .cornerRadius(2)
                .shimmering()
                .padding(.top, 4)
        }
        .frame(width: 180)
    }
}

// MARK: - Shimmering Effect
extension View {
    func shimmering() -> some View {
        self.modifier(ShimmeringEffect())
    }
}

struct ShimmeringEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        gradient: Gradient(stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .white.opacity(0.5), location: 0.3),
                            .init(color: .white.opacity(0.5), location: 0.7),
                            .init(color: .clear, location: 1)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2) * phase)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)) {
                    self.phase = 1
                }
            }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}

// MARK: - Book Extension for LibraryBook conversion
extension Book {
    init(from libraryBook: LibraryBook) {
        self.init(
            id: libraryBook.id,
            title: libraryBook.title,
            author: [libraryBook.author], // Convert single author to array
            genre: libraryBook.genre ?? "Unknown",
            publicationDate: libraryBook.publicationDate ?? "Unknown",
            totalCopies: libraryBook.totalCopies ?? 0,
            availableCopies: libraryBook.availableCopies ?? 0,
            ISBN: libraryBook.ISBN ?? "",
            Description: libraryBook.Description,
            shelfLocation: libraryBook.shelfLocation,
            dateAdded: libraryBook.dateAdded ?? "",
            publisher: libraryBook.publisher,
            imageLink: libraryBook.imageLink
        )
    }
}

// MARK: - AllBooksView
struct AllBooksView: View {
    let title: String
    let books: [LibraryBook]
    let isLoading: Bool
    @Environment(\.presentationMode) var presentationMode
    @State private var gridColumns = [GridItem(.adaptive(minimum: 160, maximum: 180), spacing: 15)]
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
                    .frame(width: 65, height: 60)
                    .overlay(
                        Rectangle()
                            .frame(height: 1.25)
                            .foregroundColor(.black)
                            .padding(.top, -1),
                        alignment: .top
                    )
                    .overlay(
                        Rectangle()
                            .frame(width: 1.25)
                            .foregroundColor(.black)
                            .padding(.trailing, -1),
                        alignment: .trailing
                    )
                    .overlay(
                        Rectangle()
                            .frame(height: 1.25)
                            .foregroundColor(.black)
                            .padding(.bottom, -1),
                        alignment: .bottom
                    )
                    .overlay(
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "arrow.left")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.black)
                        }
                        .padding(.leading, 20),
                        alignment: .leading
                    )
                
                Rectangle()
                    .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
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
                            .frame(width: 1.25)
                            .foregroundColor(.black)
                            .padding(.leading, -1),
                        alignment: .leading
                    )
                    .overlay(
                        Rectangle()
                            .frame(height: 1.25)
                            .foregroundColor(.black)
                            .padding(.bottom, -1),
                        alignment: .bottom
                    )
            }
            .overlay(
                Text(title)
                    .font(.custom("Charter", size: 20))
                    .bold()
                    .foregroundColor(.black),
                alignment: .center
            )
            .frame(width: 400)
            .padding(.horizontal, -20)
            
            // Content
            if isLoading {
                GridBooksSkeleton()
            } else if books.isEmpty {
                VStack {
                    Image(systemName: "book.closed")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .padding()
                    
                    Text("No books available")
                        .font(.custom("Charter", size: 18))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 25) {
                        ForEach(books) { book in
                            NavigationLink(destination: BookDetailView(book: Book(from: book))) {
                                GridBookCard(book: book)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationBarHidden(true)
        .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
    }
}

// MARK: - GridBookCard
struct GridBookCard: View {
    let book: LibraryBook
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // Book Cover with Black Square Border
            ZStack {
                Rectangle()
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 140, height: 185)
                
                if let imageUrl = book.imageLink, !imageUrl.isEmpty {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    .frame(width: 135, height: 180)
                    .clipped()
                    .background(Color.white)
                } else {
                    Image(systemName: "book.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 70)
                        .foregroundColor(.gray)
                        .frame(width: 135, height: 180)
                        .background(Color.white)
                }
            }
            
            // Text Container
            VStack(alignment: .center, spacing: 4) {
                Text(book.title)
                    .font(.custom("Charter", size: 14))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .frame(height: 40)
                
                Text(book.author)
                    .font(.custom("Charter", size: 12))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .frame(width: 140)
        }
        .frame(width: 160, height: 270)
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
    }
}

// MARK: - GridBooksSkeleton
struct GridBooksSkeleton: View {
    let columns = [GridItem(.adaptive(minimum: 160, maximum: 180), spacing: 15)]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 25) {
                ForEach(0..<10, id: \.self) { _ in
                    GridBookCardSkeleton()
                }
            }
            .padding()
        }
    }
}

// MARK: - GridBookCardSkeleton
struct GridBookCardSkeleton: View {
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            // Skeleton for book cover
            ZStack {
                Rectangle()
                    .stroke(Color.black, lineWidth: 1.5)
                    .frame(width: 140, height: 185)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 135, height: 180)
                    .shimmering()
            }
            
            // Skeleton for title
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 14)
                .cornerRadius(2)
                .shimmering()
                .padding(.top, 4)
                .frame(height: 40)
            
            // Skeleton for author
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 80, height: 12)
                .cornerRadius(2)
                .shimmering()
        }
        .frame(width: 160, height: 270)
        .background(Color(red: 255/255, green: 239/255, blue: 210/255))
    }
}
