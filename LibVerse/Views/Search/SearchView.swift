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
                // Background color
                Color(red: 255/255, green: 243/255, blue: 230/255)
                    .ignoresSafeArea()
                
                // Main content
                VStack(spacing: 0) {
                    // Orange section with search at top
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Search")
                            .font(.custom("Menlo-Bold", size: 24))
                            .padding(.horizontal)
                        
                        HStack(spacing: 0) {
                            TextField("Title, author, host, or topic", text: $searchText)
                                .padding()
                                .frame(width: 300, height: 59)
                                .font(.custom("Menlo", size: 15))
                                .background(Color(.systemBackground))
                                .cornerRadius(0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.black, lineWidth: 1.25)
                                )
                                .onChange(of: searchText) { _ in
                                    dataController.updateSuggestions(for: searchText)
                                }
                            
                            Button(action: {
                                showSearchResults = true
                            }) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                }
                                .frame(width: 40, height: 59)
                                .padding(.horizontal, 16)
                                .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                                .foregroundColor(.black)
                                .cornerRadius(0)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.black, lineWidth: 1.25)
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                    
                    // Categories List
                    ScrollView {
                        VStack(spacing: 0) {
                            ForEach(categories, id: \.0) { category, icon in
                                VStack(spacing: 0) {
                                    HStack {
                                        Image(systemName: icon)
                                            .foregroundColor(.black)
                                            .frame(width: 24, height: 24)
                                        Text(category)
                                            .font(.custom("Menlo", size: 15))
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
                                .background(Color(red: 255/255, green: 243/255, blue: 230/255))
                            }
                        }
                    }
                    .background(Color(red: 255/255, green: 243/255, blue: 230/255))
                }
                
                // Suggestions overlay
                if !dataController.suggestions.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(dataController.suggestions, id: \.id) { book in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(book.title)
                                    .font(.custom("Menlo", size: 16))
                                    .fontWeight(.bold)
                                Text("by \(book.author.joined(separator: ", "))")
                                    .font(.custom("Menlo", size: 14))
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white) // Background for each row
                            .onTapGesture {
                                searchText = book.title // Auto-fill the search field
                                dataController.suggestions = [] // Clear suggestions
                            }
                        }
                    }
                    .frame(width: 375)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 4)
                    .padding(.top, -265)
                }
            }
            .navigationBarHidden(true)
            .background(
                NavigationLink(destination: SearchResultView(searchText: searchText, selectedCategory: selectedCategory, dataController: dataController), isActive: $showSearchResults) {
                    EmptyView()
                }
            )
            .onAppear {
                // Fetch books when the view appears
                dataController.fetchBooks()
            }
        }
    }
}
#Preview {
    SearchView()
}
