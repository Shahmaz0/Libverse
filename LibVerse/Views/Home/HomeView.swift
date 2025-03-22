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
            
            MyShelfView()
                .tabItem {
                    Image(systemName: "books.vertical.fill")
                    Text("MyShelf")
                }
                .tag(2)
            
            MyBookView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("MyBook")
                }
                .tag(3)
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
    let popularBooks: [PopularBook] = [
        PopularBook(imageName: "mvc", title: "MVC", author: "R.S. Salaria", rating: 4, isBookmarked: true),
        PopularBook(imageName: "warandpeace", title: "War and Peace", author: "Leo Tolstoy", rating: 5, isBookmarked: false),
        PopularBook(imageName: "harrypotter", title: "Harry Potter", author: "J.K. Rowling", rating: 5, isBookmarked: true)
    ]
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                ScrollView {
                    // Padding to push content below the fixed header
                    VStack(alignment: .leading, spacing: 5) {
                        Color.clear.frame(height: 50) // Reduced from 120 to 80

                        // Popular Section 1
                        VStack(alignment: .leading, spacing: 10) {
                            sectionHeader(title: "Popular")
                            horizontalBookScroll()
                        }
                        
                        // Popular Section 2
                        VStack(alignment: .leading, spacing: 10) {
                            sectionHeader(title: "Popular")
                            horizontalBookScroll()
                        }
                        
                        // Recently Added
                        VStack(alignment: .leading, spacing: 10) {
                            sectionHeader(title: "Recently Added")
                            horizontalBookScroll()
                        }
                    }
                    .padding(.vertical)
                }
                .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))

                // Fixed Header with Title and Alert/Profile
                VStack(spacing: 8) {
                    HStack {
                        Button(action: {
                            // Alert button action
                        }) {
                            Image(systemName: "bell.fill")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(.orange)
                        }
                        
                        Spacer()

                        Text("Libverse")
                            .font(.largeTitle)
                            .bold()
                        
                        Spacer()
                        
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.orange)
                    }
                    .padding(.horizontal)
                    .frame(height: 50)
                }
                .background(Color(red: 255/255, green: 239/255, blue: 210/255))
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
    
    // Helper for horizontal scroll of books
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
}
// Announcements Section
//                    VStack(alignment: .leading, spacing: 15) {
//                        HStack {
//                            Text("Announcements")
//                                .font(.title2)
//                                .bold()
//                            Spacer()
//                            Button("See All") {
//                                // Action
//                            }
//                            .foregroundColor(.orange)
//                            .font(.system(size: 16, weight: .medium))
//                        }
//                        .padding(.horizontal)
//
//                        ScrollView(.horizontal, showsIndicators: false) {
//                            HStack(spacing: 15) {
//                                ForEach(0..<3) { _ in
//                                    AnnouncementCard()
//                                }
//                            }
//                            .padding(.horizontal)
//                        }
//                    }


// MARK: - Announcement Card
//struct AnnouncementCard: View {
//    var body: some View {
//        VStack(alignment: .leading, spacing: 10) {
//            Text("Announcement Title")
//                .font(.headline)
//            Text("This is a sample announcement text that describes the important information.")
//                .font(.subheadline)
//                .foregroundColor(.gray)
//                .lineLimit(2)
//        }
//        .padding()
//        .frame(width: 250)
//        .frame(height: 200)
//        .background(Color(.systemGray6))
//        .cornerRadius(12)
//    }
//}

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
