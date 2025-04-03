//
//  MyBook.swift
//  LibVerse
//
//  Created by Shahma Ansari on 02/04/25.
//

import SwiftUI
import Combine

struct MyBook: View {
    @StateObject private var supabaseManager = SupabaseManager.shared
    @State private var selectedTab = 0
    
    // Book data states
    @State private var currentlyBorrowedBooks: [Book] = []
    @State private var borrowingHistoryBooks: [Book] = []
    @State private var bookIssues: [BookIssue] = []
    @State private var isLoading = false
    
    // Menu and alert states
    @State private var selectedBook: Book?
    @State private var showingMenu = false
    @State private var showingLostAlert = false
    @State private var showingLostConfirmationAlert = false
    
    var body: some View {
        ZStack {
            Color(red: 255/255, green: 239/255, blue: 210/255)
                .ignoresSafeArea()
            
            // Header (fixed at top)
            VStack(spacing: 0) {
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
                            .frame(height: 1.25)
                            .foregroundColor(.black)
                            .padding(.bottom, -1),
                        alignment: .bottom
                    )
                    .overlay(
                        HStack(spacing: 0) {
                            Text("Borrowed")
                                .font(.custom("Charter", size: 20))
                                .bold()
                                .foregroundColor(.black)
                                .padding(.leading, 20)
                            
                            Spacer()
                        }
                    )
                
                Spacer().frame(height: 10)
                
                VStack() {
                    Picker("View", selection: $selectedTab) {
                        Text("Currently Borrowed").tag(0)
                        Text("Borrowing History").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .background(
                        Color(red: 255/255, green: 239/255, blue: 210/255)
                        .cornerRadius(0) // Remove corner radius
                    )
                    .onAppear {
                        // Customize segmented control appearance
                        UISegmentedControl.appearance().selectedSegmentTintColor = .orange
                        UISegmentedControl.appearance().setTitleTextAttributes(
                            [.foregroundColor: UIColor.white],
                            for: .selected
                        )
                        UISegmentedControl.appearance().setTitleTextAttributes(
                            [.foregroundColor: UIColor.black],
                            for: .normal
                        )
                        UISegmentedControl.appearance().backgroundColor = UIColor(
                            red: 255/255,
                            green: 239/255,
                            blue: 210/255,
                            alpha: 1.0
                        )
                    }
                    
                    // Content based on selected tab
                    if isLoading {
                        ProgressView()
                            .padding(.vertical, 50)
                    } else {
                        if selectedTab == 0 {
                            currentlyBorrowedBooksList
                        } else {
                            borrowingHistoryList
                        }
                    }
                }
                .background(Color(red: 255/255, green: 239/255, blue: 210/255))
                
                Spacer()
            }
        }
        .task {
            await loadBooks()
        }
        .alert("Mark Book as Lost", isPresented: $showingLostAlert) {
            Button("Cancel", role: .cancel) {
                selectedBook = nil
            }
            Button("Yes", role: .destructive) {
                showingLostConfirmationAlert = true
            }
        } message: {
            Text("Are you sure you want to mark this book as lost?")
        }
        .alert("Final Confirmation", isPresented: $showingLostConfirmationAlert) {
            Button("Cancel", role: .cancel) {
                selectedBook = nil
            }
            Button("Yes, I Lost It", role: .destructive) {
                if let book = selectedBook {
                    Task {
                        await markBookAsLost(book)
                    }
                }
            }
        } message: {
            Text("This action cannot be undone. Are you absolutely sure you have lost this book?")
        }
    }
    
    
    // MARK: - Data Loading
    
    private func loadBooks() async {
        guard let userId = supabaseManager.currentUser?.id else { return }
        
        isLoading = true
        
        do {
            // Fetch currently borrowed books (issued or overdue)
            let activeIssues: [BookIssue] = try await supabaseManager.client
                .from("BookIssue")
                .select()
                .eq("memberId", value: userId)
                .in("status", values: ["Issued", "Overdue"])
                .execute()
                .value
            
            // Fetch borrowing history (returned books)
            let returnedIssues: [BookIssue] = try await supabaseManager.client
                .from("BookIssue")
                .select()
                .eq("memberId", value: userId)
                .eq("status", value: "Returned")
                .execute()
                .value
            
            // Get book details
            currentlyBorrowedBooks = try await fetchBooks(for: activeIssues)
            borrowingHistoryBooks = try await fetchBooks(for: returnedIssues)
            bookIssues = activeIssues + returnedIssues
            
        } catch {
            print("Error loading books: \(error)")
        }
        isLoading = false
    }
    
    private func fetchBooks(for issues: [BookIssue]) async throws -> [Book] {
        guard !issues.isEmpty else { return [] }
        
        let bookIds = issues.map { $0.bookId }
        
        let books: [Book] = try await supabaseManager.client
            .from("Books")
            .select()
            .in("id", values: bookIds)
            .execute()
            .value
        
        return books
    }
    
    // MARK: - Book Actions
    
    private func markBookAsLost(_ book: Book) async {
        guard let userId = supabaseManager.currentUser?.id else { return }
        
        do {
            // Update the is_lost status in BookIssue table
            try await supabaseManager.client
                .from("BookIssue")
                .update(["is_lost": true])
                .eq("memberId", value: userId)
                .eq("bookId", value: book.id)
                .in("status", values: ["Issued", "Overdue"])
                .execute()
            
            // Refresh the books list
            await loadBooks()
            
            // Clear the selected book
            selectedBook = nil
        } catch {
            print("Error marking book as lost: \(error)")
        }
    }
    
    // MARK: - Subviews
    
    private var currentlyBorrowedBooksList: some View {
        Group {
            if currentlyBorrowedBooks.isEmpty {
                Text("No books currently borrowed")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(currentlyBorrowedBooks) { book in
                            let issue = bookIssues.first { $0.bookId == book.id }
                            let isLost = issue?.isLost ?? false
                            
                            BookCard(
                                BookImage: book.imageLink ?? "",
                                title: book.title,
                                author: book.author.joined(separator: ", "),
                                description: book.Description ?? "No description available",
                                showPlusButton: false,
                                menuAction: isLost ? nil : {
                                    selectedBook = book
                                    showingLostAlert = true
                                },
                                dueDate: issue?.dueDate,
                                fine: issue?.fine,
                                isLost: isLost
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
    
    private var borrowingHistoryList: some View {
        Group {
            if borrowingHistoryBooks.isEmpty {
                Text("No borrowing history found")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(borrowingHistoryBooks) { book in
                            BookCard(
                                BookImage: book.imageLink ?? "",
                                title: book.title,
                                author: book.author.joined(separator: ", "),
                                description: book.Description ?? "No description available",
                                showPlusButton: false
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
}

struct MyBook_Previews: PreviewProvider {
    static var previews: some View {
        MyBook()
    }
}

#Preview {
    MyBook()
}
