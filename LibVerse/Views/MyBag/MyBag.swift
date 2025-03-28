//
//  MyBag.swift
//  LibVerse
//
//  Created by Shahma Ansari on 26/03/25.
//

import SwiftUI

struct MyBag: View {
    @StateObject private var viewModel = MyBagViewModel()
    @EnvironmentObject var supabaseManager: SupabaseManager
    
    var body: some View {
        ZStack {
            Color(red: 255/255, green: 239/255, blue: 210/255)
                .ignoresSafeArea()
            
            VStack {
                // Header
                HStack(spacing: 0) {
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
                    
                    Rectangle()
                        .fill(Color(red: 255/255, green: 239/255, blue: 210/255))
                        .frame(maxWidth: 90, maxHeight: 60)
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
                            Image(systemName: "square.and.pencil")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.trailing, 15)
                                .foregroundColor(.black),
                            alignment: .center
                        )
                }
                .overlay(
                    Text("My Bag")
                        .font(.custom("Charter", size: 20))
                        .bold()
                        .foregroundColor(.black),
                    alignment: .center
                )
                .frame(maxWidth: .infinity)
                .padding(.horizontal, -20)
                
                // Content
                if viewModel.isLoading {
                    ProgressView()
                        .padding(.top, 50)
                } else if viewModel.bagBooks.isEmpty {
                    Text("Your bag is empty")
                        .font(.custom("Charter", size: 16))
                        .foregroundColor(.gray)
                        .padding(.top, 300)
                } else {
                    ScrollView {
                        VStack(spacing: 1) {
                            ForEach(viewModel.bagBooks, id: \.id) { book in
                                BookCard(
                                    BookImage: book.imageLink ?? "",
                                    title: book.title,
                                    author: book.author.joined(separator: ", "),
                                    description: book.Description ?? "No description available"
                                )
                            }
                        }
                    }
                }
                Spacer()
                
                Button(action: {
                    print("Issue All clicked.")
                }) {
                    Text("Issue all")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(red: 255/255, green: 111/255, blue: 45/255))
                        .foregroundColor(.white)
                        .cornerRadius(0)
                }
                .frame(width: 345, height: 30, alignment: .center)
                .padding(.bottom, 20)
            }
        }
        .onAppear {
            viewModel.fetchBagBooks()
        }
    }
}

class MyBagViewModel: ObservableObject {
    @Published var bagBooks: [Book] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let supabaseManager = SupabaseManager.shared
    
    func fetchBagBooks() {
        guard let currentUser = supabaseManager.currentUser else {
            // If no user is logged in, show empty state
            self.bagBooks = []
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                // 1. Fetch the current user's bag book IDs from Member table
                let query = supabaseManager.client
                    .from("Member")
                    .select()
                    .eq("id", value: currentUser.id)
                
                let members: [Member] = try await query.execute().value
                
                guard let member = members.first else {
                    await MainActor.run {
                        self.isLoading = false
                        self.bagBooks = []
                    }
                    return
                }
                
                // Handle optional myBag array
                let bagIds = member.myBag
                
                // 2. If the user has no books in bag, return empty
                if bagIds.isEmpty {
                    await MainActor.run {
                        self.isLoading = false
                        self.bagBooks = []
                    }
                    return
                }
                
                // Convert array of bag UUID strings to an array of UUIDs for querying
                let bookIds = bagIds.compactMap { UUID(uuidString: $0) }
                
                // 3. Fetch all bag books at once using the array of UUIDs
                let bookQuery = supabaseManager.client
                    .from("Books")
                    .select()
                    .in("id", values: bookIds)
                
                let books: [Book] = try await bookQuery.execute().value
                
                await MainActor.run {
                    self.bagBooks = books
                    self.isLoading = false
                }
            } catch {
                print("Error fetching bag books: \(error)")
                await MainActor.run {
                    self.isLoading = false
                    self.errorMessage = "Failed to load bag books. Please try again."
                    self.bagBooks = []
                }
            }
        }
    }
}

#Preview {
    MyBag()
        .environmentObject(SupabaseManager.shared)
}
