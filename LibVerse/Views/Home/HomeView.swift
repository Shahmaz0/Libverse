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
                    Image(systemName: "books.vertical.fill")
                    Text("MyShelf")
                }
                .tag(0)
            
//            SearchView()
//                .tabItem {
//                    Image(systemName: "magnifyingglass")
//                    Text("Search")
//                }
//                .tag(1)
            
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
    let popularBooks: [PopularBook] = [
        PopularBook(imageName: "mvc", title: "MVC", author: "R.S. Salaria", rating: 4, isBookmarked: true),
        PopularBook(imageName: "warandpeace", title: "War and Peace", author: "Leo Tolstoy", rating: 5, isBookmarked: false),
        PopularBook(imageName: "harrypotter", title: "Harry Potter", author: "J.K. Rowling", rating: 5, isBookmarked: true)
    ]
    
    var body: some View {
            NavigationView {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        horizontalBookScroll()
                    }
                    .padding(.vertical)
                }
                .background(Color(red: 255/255, green: 239/255, blue: 210/255).edgesIgnoringSafeArea(.all))
                            .navigationTitle("Favourites") // Large title here
                            .navigationBarTitleDisplayMode(.large) // Makes it large
                        
                    
                    
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
                ForEach(popularBooks) { book in
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
